---
layout: post
title: Making Async MySQL Executor Pool in Play 2.5
---

The default Play 2.5 Java API does not support JPA call asynchronously properly. For example, you may sometimes see `java.lang.IllegalStateException: Session/EntityManager is closed` when using `jpaApi.withTransaction()` in `httpExecutionContext.current()`. The code snippet here:

    return authProvider
        .verifyAccessToken(unverifedToken, httpExecutionContext.current())
        .thenApplyAsync(token -> { /* ... */ }, httpExecutionContext.current());

And the sample log here:

    [2016-11-14 17:49:30,816][DEBUG][org.hibernate.SQL] - pool-31-thread-4 - select user1_.id as id1_9_, ...
    [2016-11-14 17:49:30,822][DEBUG][org.hibernate.SQL] - pool-31-thread-5 - select securityro0_.id as id1_7_, ...
    [2016-11-14 17:49:30,868][DEBUG][org.hibernate.SQL] - pool-31-thread-5 - insert into User (createdAt, ...
    [2016-11-14 17:49:30,870][DEBUG][org.hibernate.SQL] - pool-31-thread-5 - insert into LinkedAccount (createdAt, ...
    [2016-11-14 17:49:30,872][ERROR][app.ErrorHandler] - pool-31-thread-5 - Server Error. Caused by: 
    java.util.concurrent.CompletionException: java.lang.IllegalStateException: Session/EntityManager is closed
        at java.util.concurrent.CompletableFuture.encodeThrowable(CompletableFuture.java:273)
        at java.util.concurrent.CompletableFuture.completeThrowable(CompletableFuture.java:280)
        at java.util.concurrent.CompletableFuture.uniApply(CompletableFuture.java:604)
        at java.util.concurrent.CompletableFuture$UniApply.tryFire(CompletableFuture.java:577)
        at java.util.concurrent.CompletableFuture$Completion.run(CompletableFuture.java:442)
        at app.utils.executors.MySQLExecutor.lambda$null$0(MySQLExecutor.java:47)
        at play.db.jpa.DefaultJPAApi.withTransaction(DefaultJPAApi.java:137)
        at play.db.jpa.DefaultJPAApi.withTransaction(DefaultJPAApi.java:95)
        at app.utils.executors.MySQLExecutor.lambda$null$1(MySQLExecutor.java:46)
        at play.core.j.HttpExecutionContext$$anon$2.run(HttpExecutionContext.scala:56)
        at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
        at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
        at java.lang.Thread.run(Thread.java:745)
    Caused by: java.lang.IllegalStateException: Session/EntityManager is closed
        at org.hibernate.internal.AbstractSharedSessionContract.checkOpen(AbstractSharedSessionContract.java:332)
        at org.hibernate.engine.spi.SharedSessionContractImplementor.checkOpen(SharedSessionContractImplementor.java:126)
        at org.hibernate.internal.SessionImpl.fireMerge(SessionImpl.java:859)
        at org.hibernate.internal.SessionImpl.merge(SessionImpl.java:845)
        at org.hibernate.internal.SessionImpl.merge(SessionImpl.java:850)
        at controllers.UserController.lambda$null$14(UserController.java:313)
        at java.util.concurrent.CompletableFuture.uniApply(CompletableFuture.java:602)
        ... 10 common frames omitted

If you look carefully, you can see that there are two threads running. But the above code should be thread safe and contain no racing condition. So the best guess is that the first async call defer its closing of the `EntityManager`. Plus the `JPAEntityManagerContext` prefers the entity manager in HTTP context rather than the thread local one. So that the second async call use the close-pending `EntityManager` rather than creating a new one.

To fix the problem, I made a customized executor to create new `EntityManager` every time.

    @ThreadSafe
    @Singleton
    public class MySQLExecutor extends AppExecutor {

        private final ExecutorService executorService;
        private final JPAApi jpaApi;

        @Inject
        public MySQLExecutor(JPAApi jpaApi) {
            this.executorService = newFixedThreadPool(100);
            this.jpaApi = jpaApi;
        }

        @Override
        public Executor current() {
            final ClassLoader contextClassLoader = Thread.currentThread().getContextClassLoader();
            final Http.Context httpContext = Http.Context.current.get();

            return command -> {
                executorService.execute(() -> {
                    Thread thread = Thread.currentThread();
                    ClassLoader oldContextClassLoader = thread.getContextClassLoader();

                    jpaApi.withTransaction((entityManager) -> {     // ** Magic call here **

                        Http.Context oldHttpContext = Http.Context.current.get();
                        thread.setContextClassLoader(contextClassLoader);
                        Http.Context.current.set(httpContext);

                        // ** Another magic **
                        final String contextKey = "entityManagerContext";
                        final Deque<EntityManager> deque = new ArrayDeque<>();
                        deque.add(entityManager);
                        Http.Context.current().args.put(contextKey, deque); // hack to the async problem

                        try {
                            command.run();
                        } finally {
                            Http.Context.current().args.remove(contextKey);
                            thread.setContextClassLoader(oldContextClassLoader);
                            Http.Context.current.set(oldHttpContext);
                        }
                        return null;
                    });
                });

            };
        }

    }

After that, you can replace any `HttpExecutionContext` to `MySQLExecutor`:

    return authProvider
        .verifyAccessToken(unverifedToken, mySQLExecutor.current())
        .thenApplyAsync(token -> { /* ... */ }, mySQLExecutor.current());



