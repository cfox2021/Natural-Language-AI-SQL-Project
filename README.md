# Restaurant Favorites: Natural Language to SQL

This project models fictional restaurant customers, their contact preferences, preferred payment methods, completed orders, and saved favorite orders. An OpenAI model converts plain-language questions into read-only SQLite queries, then summarizes the returned rows.

## Project files

- `db_bot.py` builds the database, runs both prompting strategies, and saves SQL, result rows, answers, and errors to JSON logs.
- `setup.sql` creates the tables, relationships, checks, and indexes.
- `setupData.sql` inserts the fictional restaurant data.
- `restaurant.sqlite` is the generated SQLite database, included with the project and rebuilt each time the bot runs.
- `schema.svg` diagrams the database.
- `examples.md` reports the eight questions, both strategies' observed results, and corrected SQL for the mistakes found.
- `sample_post.md` contains the class-post write-up.
- `results/` contains the latest eight-question run logs for both strategies.
- `config.example.json` documents the local config-file format. It contains only a placeholder; never commit a real `config.json` or API key.

## Setup and run in Windows PowerShell

Open PowerShell in this project folder. Create and activate a virtual environment, then install the dependencies:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

Set your OpenAI key for the current PowerShell window and run the bot:

```powershell
$env:OPENAI_API_KEY = Read-Host "OpenAI API key"
python .\db_bot.py
```

The default model is `gpt-4o-mini`. To choose a different available model for one run, set `OPENAI_MODEL` first, for example:

```powershell
$env:OPENAI_MODEL = "gpt-4o"
```

The bot also accepts a local `config.json` with an `openaiKey` value. Copy `config.example.json` to `config.json` and add the key locally if you prefer; `.gitignore` excludes that file. Keep the key private and do not include it in class posts or GitHub.

The script rebuilds `restaurant.sqlite` from `setup.sql` and `setupData.sql` every run. The eight questions include the student-authored question “Customers who prefer Google Pay or Apple Pay.” Each of the two strategies makes one model request for SQL and a second request for a natural-language answer per question. Review generated SQL and returned rows because an answer can sound convincing even when its query is wrong.

## Database design

`customer` is the parent record. Customers can have multiple `contact_info` and `payment_method` rows. `customer_order` records purchases and `order_item` records their line items. Each line snapshots its price in `price_at_order`, so later menu price changes do not alter past totals. `favorite_order` and `favorite_order_item` separately represent saved meal combinations. The sample contact values and payment last-four values are fictional; the schema does not store full card numbers.

## Prompting strategies and results

- `zero_shot` sends the model the schema and instructions without a worked example.
- `single_domain_double_shot` adds a restaurant question and SQL example before asking the question.

Both strategies receive the same schema, data, and questions. The latest run logs and comparison are included in `results/` and `examples.md`. The project demonstrates that execution success alone does not establish that SQL answers the intended question.

## Assignment submission checklist

The project package includes the working code, SQLite database, schema image, a purpose statement, one successful example, one unsuccessful example, eight additional question examples, a comparison of two prompting strategies, and the latest response logs. `sample_post.md` is ready to use as the project description for the class channel or GitHub repository.

Before submitting, read the assigned paper and complete your individual self-report in Canvas. Post the project and complete the required reviews of at least three classmates' posts.
