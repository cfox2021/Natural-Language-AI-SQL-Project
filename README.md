# Restaurant Favorites: Natural Language to SQL

This project models fictional restaurant customers, their contact preferences, preferred payment methods, completed orders, and saved favorite orders. An OpenAI model converts plain-language questions into read-only SQLite queries, then summarizes the returned rows.

## Project files

- `db_bot.py` builds the database, runs both prompting strategies, and saves SQL, result rows, answers, and errors to JSON logs.
- `setup.sql` creates the tables, relationships, checks, and indexes.
- `setupData.sql` inserts the fictional restaurant data.
- `restaurant.sqlite` is the generated SQLite database, included with the project and rebuilt each time the bot runs.
- `schema.jpg` diagrams the database.
- `examples.md` reports the eight questions, both strategies' observed results, and corrected SQL for the mistakes found.
- `results/` contains the latest eight-question run logs for both strategies.
