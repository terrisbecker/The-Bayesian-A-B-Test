# The Bayesian A/B Test
In this tutorial, I’ll demonstrate my approach to analyzing data from an A/B test. The main tutorial can be found [here](https://terrisbecker.github.io/The-Bayesian-A-B-Test/index.html). Below is a description of the files and data used in the tutorial.

## sim_data.csv
This is the data set that we will be analyzed. The data is simulated, but it is representative of data from an actual A/B test. Below are a few lines from the dataset.

|        time  | AClick | BClick | ATotal | BTotal |       APct |     BPct  | 
| ------------ |--------|--------|--------|--------|------------|---------- |
| 1 2020-01-02 |   348  |   362  |  2889  |  2894  | 0.1204569  | 0.1250864 |
| 2 2020-01-03 |  1110  |  1122  |  9599  |  9578  | 0.1156370  | 0.1171435 |
| 3 2020-01-04 |  1883  |  1932  | 16228  | 16233  | 0.1160340  | 0.1190168 |
| 4 2020-01-05 |  2641  |  2733  | 22814  | 22771  | 0.1157623  | 0.1200211 |
| 5 2020-01-06 |  3489  |  3511  | 29658  | 29455  | 0.1176411  | 0.1191988 |
| 6 2020-01-07 |  4265  |  4316  | 36361  | 36133  | 0.1172960  | 0.1194476 |

Note that the columns ATotal and BTotal are running totals. That is, the value in the cell is a total count up to that point in time.
