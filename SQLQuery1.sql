CREATE DATABASE test1
	ON
	(
	NAME="test1",
	FILENAME="C:\Shengcai\test2.mdf",
	SIZE=2MB,
	MAXSIZE=50MB,
	FILEGROWTH=10%
	)
	LOG ON
	(
		NAME="test_log",
		FILENAME="C:\Shengcai\test2.ldf",
		SIZE=2MB,
		MAXSIZE=5MB,
		FILEGROWTH=1MB
	)	