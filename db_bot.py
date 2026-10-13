"""Natural-language interface for the sample restaurant SQLite database."""

import json
import os
import re
import sqlite3
from datetime import datetime
from pathlib import Path

from openai import OpenAI


BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / "restaurant.sqlite"
SCHEMA_PATH = BASE_DIR / "setup.sql"
DATA_PATH = BASE_DIR / "setupData.sql"
CONFIG_PATH = BASE_DIR / "config.json"
RESULTS_DIR = BASE_DIR / "results"
MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")


def load_api_key():
    """Prefer an environment variable; allow the starter-style config file too."""
    api_key = os.getenv("OPENAI_API_KEY")
    if api_key:
        return api_key
    if CONFIG_PATH.exists():
        with CONFIG_PATH.open(encoding="utf-8") as config_file:
            api_key = json.load(config_file).get("openaiKey")
    if not api_key or api_key == "need to replace with your open ai key":
        raise RuntimeError(
            "Set OPENAI_API_KEY or copy config.example.json to config.json and add your key."
        )
    return api_key


def initialize_database():
    """Rebuild the sample database from the checked-in SQL scripts."""
    if DB_PATH.exists():
        DB_PATH.unlink()
    connection = sqlite3.connect(DB_PATH)
    connection.execute("PRAGMA foreign_keys = ON")
    connection.executescript(SCHEMA_PATH.read_text(encoding="utf-8"))
    connection.executescript(DATA_PATH.read_text(encoding="utf-8"))
    connection.commit()
    return connection


def read_only_authorizer(action, arg1, arg2, database_name, trigger_name):
    """Let model-generated SQL read data, while denying writes and schema changes."""
    allowed = {
        sqlite3.SQLITE_SELECT,
        sqlite3.SQLITE_READ,
        sqlite3.SQLITE_FUNCTION,
        getattr(sqlite3, "SQLITE_RECURSIVE", -1),
    }
    return sqlite3.SQLITE_OK if action in allowed else sqlite3.SQLITE_DENY


def sanitize_sql(value):
    """Remove a Markdown code fence if the model includes one."""
    value = value.strip()
    if value.startswith("```"):
        value = re.sub(r"^```(?:sql|sqlite)?\s*", "", value, count=1, flags=re.IGNORECASE)
        value = re.sub(r"\s*```$", "", value, count=1)
    return value.strip()


def run_sql(connection, query):
    query = sanitize_sql(query)
    if not query.lower().startswith(("select", "with")):
        raise ValueError("Only SELECT queries are allowed.")
    connection.set_authorizer(read_only_authorizer)
    try:
        cursor = connection.execute(query)
        columns = [item[0] for item in cursor.description or []]
        rows = [list(row) for row in cursor.fetchall()]
        return columns, rows
    finally:
        connection.set_authorizer(None)


def get_chat_response(client, content):
    response = client.chat.completions.create(
        model=MODEL,
        messages=[{"role": "user", "content": content}],
    )
    return response.choices[0].message.content or ""


SCHEMA_SQL = SCHEMA_PATH.read_text(encoding="utf-8")
SQL_INSTRUCTIONS = (
    " Give me one SQLite SELECT statement that answers the question. "
    "Use only tables and columns in the schema. Return SQL only, without Markdown or explanation."
)

STRATEGIES = {
    "zero_shot": SCHEMA_SQL + SQL_INSTRUCTIONS,
    "single_domain_double_shot": (
        SCHEMA_SQL
        + " Example question: Which customers saved a favorite order containing Margherita Pizza?\n"
        + "Example SQL: SELECT DISTINCT c.first_name || ' ' || c.last_name AS customer_name, "
        + "fo.nickname FROM customer c JOIN favorite_order fo ON c.customer_id = fo.customer_id "
        + "JOIN favorite_order_item foi ON fo.favorite_order_id = foi.favorite_order_id "
        + "JOIN menu_item mi ON foi.menu_item_id = mi.menu_item_id "
        + "WHERE mi.item_name = 'Margherita Pizza';\n"
        + SQL_INSTRUCTIONS
    ),
}

QUESTIONS = [
    "Which customers have placed the most completed orders?",
    "Which menu items have sold the most by quantity?",
    "How many customers prefer each payment method?",
    "Which customers do not have a phone number that can receive SMS?",
    "What items are in Maya Chen's Friday Pizza Night favorite order?",
    "Which customers have ordered Chocolate Cake, and on what dates?",
    "How much has each customer spent on completed orders?",
    "Customers who prefer Google Pay or Apple Pay",
]


def main():
    client = OpenAI(api_key=load_api_key())
    connection = initialize_database()
    RESULTS_DIR.mkdir(exist_ok=True)
    try:
        for strategy_name, prompt_prefix in STRATEGIES.items():
            response_log = {
                "strategy": strategy_name,
                "model": MODEL,
                "prompt_prefix": prompt_prefix,
                "questionResults": [],
            }
            print("#" * 74)
            print(f"Running strategy: {strategy_name} (model: {MODEL})")

            for question in QUESTIONS:
                result = {
                    "question": question,
                    "sql": None,
                    "columns": [],
                    "rows": [],
                    "friendlyResponse": None,
                    "error": None,
                }
                print("~" * 74)
                print(f"Question: {question}")
                try:
                    prompt = prompt_prefix + "\nQuestion: " + question
                    sql = sanitize_sql(get_chat_response(client, prompt))
                    result["sql"] = sql
                    columns, rows = run_sql(connection, sql)
                    result.update({"columns": columns, "rows": rows})
                    print("SQL:\n" + sql)
                    print("Rows:", rows)

                    answer_prompt = (
                        "Answer the user's question briefly using only the database result below. "
                        "If the result is empty, say that no matching records were found. "
                        "Do not infer details that are not present.\n"
                        f"Question: {question}\n"
                        f"Column names: {json.dumps(columns)}\n"
                        f"Rows: {json.dumps(rows, ensure_ascii=False)}"
                    )
                    answer = get_chat_response(client, answer_prompt)
                    result["friendlyResponse"] = answer
                    print("Answer:", answer)
                except Exception as error:  # Keep one failed question from stopping the rest.
                    result["error"] = str(error)
                    print("Error:", error)
                response_log["questionResults"].append(result)

            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_path = RESULTS_DIR / f"response_restaurant_{strategy_name}_{timestamp}.json"
            output_path.write_text(json.dumps(response_log, indent=2), encoding="utf-8")
            print(f"Saved results to {output_path.name}")
    finally:
        connection.close()
    print("Done!")


if __name__ == "__main__":
    main()
