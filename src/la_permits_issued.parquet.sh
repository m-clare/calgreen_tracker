URL="https://data.lacity.org/resource/pi9x-tg5x.csv?\$where=issue_date>'2024-06-01T00:00:00.000'&\$limit=1000000"

# Use the data loader cache directory to store the downloaded data.
TMPDIR="src/.observablehq/cache/"

# Download the data
curl "$URL" -o "$TMPDIR/$CODE.csv"

# Generate a Parquet file using DuckDB.
duckdb :memory: << EOF
COPY (
  SELECT *
  FROM read_csv('$TMPDIR/$CODE.csv')
  WHERE true
) TO STDOUT (FORMAT 'parquet', COMPRESSION 'gzip');
EOF
