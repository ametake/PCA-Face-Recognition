# PCA-Face-Recognition
A face recognition program based on PCA, using MATLAB.
This is also my final project for the class SI131 Linear Algebra.

Dataset: The Extended Yale Face Database B
LaTex Template: ACM Conference Proceedings - New Master Template

The report.pdf describes the whole program, including the idea, the mathematical theory, the realization and the parameters' optimization. 

SRBFR.m is the main function, while PCA.m realizes sparse representation with the same function of the built-in function pca.m. pca.m optimized the calculate to avoid huge matrix so that it runs faster, thus it is better to replace the 'PCA()' into lowercase when testing my program.
