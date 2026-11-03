# PostgreSQL Fundamentals

A runnable, beginner-friendly SQL script covering table design, data changes,
filtering, aggregation, and joins in PostgreSQL.

## Learning objectives

- Create tables with identity primary keys, `NOT NULL`, `UNIQUE`, and `CHECK`
  constraints.
- Insert, update, and (optionally) delete rows.
- Filter and order results with `WHERE`, `IN`, `BETWEEN`, `LIKE`, `ORDER BY`,
  and `LIMIT`.
- Summarize data with aggregate functions, `GROUP BY`, and `HAVING`.
- Model a many-to-many relationship and query it with `INNER`, `LEFT`, `RIGHT`,
  `FULL OUTER`, and `CROSS` joins.

## Schema and relationships

- `students` stores each student's name, age, and optional email. A student's
  email is unique when provided. The age check restricts values to 0–120.
- `courses` stores uniquely named courses.
- `enrollments` links students and courses. Its foreign keys require both sides
  of an enrollment to exist, and a unique constraint prevents duplicate
  enrollment in the same course.

The relationship is many-to-many: a student can enroll in multiple courses,
and each course can have multiple students. The `enrollments` table represents
that relationship. Deleting a referenced student or course is restricted by
the default foreign-key behavior until its enrollments are removed.

## Run the script

The script requires PostgreSQL and the `psql` command-line client. From the
repository directory, connect to a development database and run:

```sh
psql -h localhost -U your_user -d your_database -f postgresql_fundamentals.sql
```

Alternatively, open `postgresql_fundamentals.sql` in a PostgreSQL-compatible
SQL client and execute it.

> **Warning:** The script begins by dropping its `enrollments`, `courses`, and
> `students` tables so it can be rerun with a clean sample dataset. Do not run
> it against a database containing data you need to keep.

The update and query examples execute as part of the script. The sample
`DELETE` statement is commented out and must be uncommented to run.
