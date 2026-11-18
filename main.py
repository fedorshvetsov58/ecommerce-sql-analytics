import sqlite3
from pathlib import Path

DB_PATH = Path("ecommerce.db")
SCHEMA_PATH = Path("schema.sql")
QUERIES_PATH = Path("queries.sql")


def init_db(conn: sqlite3.Connection) -> None:
    # Create tables from schema.sql
    schema_sql = SCHEMA_PATH.read_text(encoding="utf-8")
    conn.executescript(schema_sql)


def seed_data(conn: sqlite3.Connection) -> None:
    # Add sample store data
    cursor = conn.cursor()

    customers = [
        ("Jan Kowalski", "jan.kowalski@example.pl", "Warsaw", "2025-01-12"),
        ("Anna Nowak", "anna.nowak@example.pl", "Krakow", "2025-02-03"),
        ("Olena Kovalenko", "olena.k@example.pl", "Warsaw", "2025-02-18"),
        ("Piotr Zielinski", "piotr.z@example.pl", "Wroclaw", "2025-03-05"),
        ("Dmytro Bondarenko", "dmytro.b@example.pl", "Gdansk", "2025-03-22"),
        ("Katarzyna Wojcik", "kasia.w@example.pl", "Warsaw", "2025-04-10"),
        ("Marek Kaminski", "marek.k@example.pl", "Poznan", "2025-05-01"),  # User with 0 orders
    ]
    cursor.executemany(
        "INSERT INTO customers (full_name, email, city, signup_date) VALUES (?, ?, ?, ?);",
        customers,
    )

    products = [
        ("Laptop Pro 14", "Electronics", 4200.00),
        ("Wireless Mouse MX", "Electronics", 320.00),
        ("Mechanical Keyboard", "Electronics", 450.00),
        ("USB-C Hub 7-in-1", "Accessories", 180.00),
        ("Laptop Backpack", "Accessories", 240.00),
        ("27-inch 4K Monitor", "Monitors", 1650.00),
        ("Monitor Arm Stand", "Accessories", 210.00),
        ("Noise Cancelling Headphones", "Audio", 890.00),
    ]
    cursor.executemany(
        "INSERT INTO products (product_name, category, price) VALUES (?, ?, ?);",
        products,
    )

    orders = [
        (1, "2025-06-01", "completed"),
        (1, "2025-06-15", "completed"),
        (2, "2025-06-05", "completed"),
        (2, "2025-06-20", "cancelled"),
        (3, "2025-06-10", "completed"),
        (3, "2025-07-02", "completed"),
        (4, "2025-06-18", "completed"),
        (4, "2025-07-05", "returned"),
        (5, "2025-06-25", "completed"),
        (6, "2025-07-08", "completed"),
    ]
    cursor.executemany(
        "INSERT INTO orders (customer_id, order_date, status) VALUES (?, ?, ?);",
        orders,
    )

    order_items = [
        (1, 1, 1),
        (1, 2, 1),
        (2, 6, 1),
        (2, 7, 1),
        (3, 8, 1),
        (3, 5, 1),
        (4, 1, 1),
        (5, 3, 1),
        (5, 2, 1),
        (5, 4, 2),
        (6, 6, 1),
        (7, 8, 2),
        (8, 3, 1),
        (9, 5, 1),
        (9, 4, 1),
        (10, 1, 1),
        (10, 8, 1),
    ]
    cursor.executemany(
        "INSERT INTO order_items (order_id, product_id, quantity) VALUES (?, ?, ?);",
        order_items,
    )

    conn.commit()


def print_table(headers: list[str], rows: list[tuple]) -> None:
    # Print query result as a simple table
    if not rows:
        print("(No data)\n")
        return

    str_rows = [[str(item) for item in row] for row in rows]
    col_widths = [
        max(len(headers[i]), max(len(r[i]) for r in str_rows))
        for i in range(len(headers))
    ]

    separator = "+-" + "-+-".join("-" * w for w in col_widths) + "-+"
    header_line = "| " + " | ".join(headers[i].ljust(col_widths[i]) for i in range(len(headers))) + " |"

    print(separator)
    print(header_line)
    print(separator)
    for row in str_rows:
        print("| " + " | ".join(row[i].ljust(col_widths[i]) for i in range(len(headers))) + " |")
    print(separator + "\n")


def run_analytics(conn: sqlite3.Connection) -> None:
    # Read and run all queries from queries.sql
    raw_sql = QUERIES_PATH.read_text(encoding="utf-8")
    queries = [q.strip() for q in raw_sql.split(";") if q.strip()]

    cursor = conn.cursor()
    for idx, query in enumerate(queries, start=1):
        title = f"Report #{idx}"
        for line in query.splitlines():
            if "QUERY" in line:
                title = line.replace("--", "").strip()
                break

        print(f"=== {title} ===")
        cursor.execute(query)
        headers = [desc[0] for desc in cursor.description]
        rows = cursor.fetchall()
        print_table(headers, rows)


def main() -> None:
    with sqlite3.connect(DB_PATH) as conn:
        init_db(conn)
        seed_data(conn)
        run_analytics(conn)


if __name__ == "__main__":
    main()