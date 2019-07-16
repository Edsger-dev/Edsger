import pandas as pd

from edsger.priority_queue_timings import sort_compare

res = []
for i in range(1,5):
    n = 10**i
    for j in range(3):
        d = sort_compare(n)
        d['trial'] = j
        d['n'] = n
        res.append(d)
res = pd.DataFrame(res)
res = res.groupby('n').min()
res.drop('trial', axis=1, inplace=True)
print(res)
