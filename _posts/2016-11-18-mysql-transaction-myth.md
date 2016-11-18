---
layout: post
title: MySQL Transaction Myth
---

How can it possible?

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

Answer: Because there are multiple transactions working on the same table; and the isolation is set to REPEATABLE-READ.

To illustrate:

	Connection 1                        Connection 2
	==================================  ==================================

	begin;
	                                    begin;

	select * from tbl;
	-- cache the tbl content ---------------------------------------------

	                                    update tbl set b = 4 where b = 2;
	-------------------------------------- it will lock the whole table --

	update tbl set b = 11 where b = 2;
	-- it will wait until Connection 2 finish ----------------------------

	                                    commit;
	-- mysql returns "0 rows affected" -----------------------------------

	select * from tbl;
	-- this will show the cached rows ------------------------------------
