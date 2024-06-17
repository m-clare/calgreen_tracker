CODE="pi9x-tg5x"
URL="https://data.lacity.org/resource/${CODE}.csv?\$query=SELECT%20*%20WHERE%20permit_sub_type%20!=%20'1%20or%202%20Family%20Dwelling'%20AND%20issue_date>'2024-06-01T00:00:00.000'%20LIMIT%201000000"

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
