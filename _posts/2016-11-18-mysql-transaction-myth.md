---
layout: post
title: MySQL Transaction Myth
---

This article illustrates a common problem when using multiple connections in MySQL. This is related to how a DBMS uses isolation level to balance performance and correctness for concurrent transactions.

The problem happens when you start a new transaction and query for some row. You then use the result to update the same row. But the database does not update as designed. 

You may check the command line output here:

	mysql> begin;
	Query OK, 0 rows affected (0.00 sec)

	mysql> select * from tbl;
	+---+------+
	| a | b    |
	+---+------+
	| 1 |    2 |
	| 2 |    2 |
	+---+------+
	2 rows in set (0.00 sec)

	mysql> update tbl set b = 11 where b = 2;
	Query OK, 0 rows affected (0.00 sec)
	Rows matched: 0  Changed: 0  Warnings: 0

	mysql> select * from tbl;
	+---+------+
	| a | b    |
	+---+------+
	| 1 |    2 |
	| 2 |    2 |
	+---+------+
	2 rows in set (0.00 sec)

	mysql> rollback;
	Query OK, 0 rows affected (0.00 sec)


Answer: Because there are multiple transactions working on the same row; and the isolation is set to REPEATABLE-READ.

This sequence diagram demostates how the problem occurs.

![Sequence Diagram]({{ site.image_base }}/2016/11/18/mysql-transaction-myth.png){: .center }

Solution 1: The program has to gain pessimistic lock in the beginning of the transaction.

Solution 2: Worse solution. It is to set the isolation level to Serializable. But the performance will deteriorate.

If the devloper does not understand fully the undelying mechanism, this can impose some hard-to-find bugs when they devlope business applications like table reservation or shopping cart.
