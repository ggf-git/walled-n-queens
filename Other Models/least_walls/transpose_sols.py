import pandas as pd

df = pd.read_csv("solutions.sol")
df = df.transpose()
df.to_csv("sols_transposed.csv")