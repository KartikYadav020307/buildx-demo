# Iris data

`iris.csv` contains the corrected 150-record Iris dataset supplied by
scikit-learn 1.8.0 (`sklearn.datasets.load_iris`) during preparation of this pack.
Features are sepal length, sepal width, petal length, and petal width in cm.
Labels: 0 = setosa; 1 = versicolor; 2 = virginica.

Primary dataset reference: Fisher, R. A. (1936), Iris,
UCI Machine Learning Repository, https://archive.ics.uci.edu/dataset/53/iris,
DOI: https://doi.org/10.24432/C56C76. The UCI dataset is distributed under
Creative Commons Attribution 4.0 International (CC BY 4.0).

The corrected loader is documented at
https://scikit-learn.org/stable/modules/generated/sklearn.datasets.load_iris.html.
The pack contains the numeric data; it does not redistribute scikit-learn code.
Training/export scripts use NumPy only.
