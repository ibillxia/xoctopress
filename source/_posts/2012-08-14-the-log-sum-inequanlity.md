---
layout: post
title: "The Log Sum Inequality"
date: 2012-08-14 21:42
comments: true
categories: Math
tags: JensenInequality
---
<p>In  mathematics, the log sum inequality is very useful for proving several theorems in information theory.</p>

<h2>1.Statements</h2>
<p>Suppose ai and bi are nonnegative numbers. The log sum inequality states that</br>
<center>$\sum_{i=1}^{n}a_{i}log \frac{a_{i}}{b_{i}} \seq a log \frac{a}{b}$,</center>
where $a=\sum a_{i}$ and $b=\sum b_{i}$. The equality established if and only if $a_{i}/b{i}$ are equal for all $i$.
</p>

<h2>2.Proof</h2>
<h3>(1)Convex functioin</h3>
<p>In mathematics, a real-valued function F(x) defined on an interval is called convex (or convex downward or concave 
upward) if the graph of the function lies below the line segment joining any two points of the graph. Equivalently, a 
function is convex if its epigraph (the set of points on or above the graph of the function) is a convex set.</p>

<!-- more -->
<p>The mathematical expressions are as follows,</br>
A real valued function $f: X → R$ defined on a convex set $X$ in a vector space is called convex if, for any two points 
$x_{1}$ and $x_{2}$ in $X$ and any $t \in [0,1]$,</br>
<center>$f(tx_{1}+(1-t)x_{2}) \leq tf(x_{1}) + (1-t)f(x_{2})$.</center>
The function is called strictly convex if remove the equal in the expression.</p>

<p>Examples of convex functions are the quadratic function $F(x)=x_{2}$ and the exponential function $F(x)=e^{x}$ for 
any real number $x$. For more examples and properties of this type of function, please refer to them on Wikipedia.</p>

<h3>(2)Jensen's inequality</h3>
<p>Jensen's inequality generalizes the statement that the secant line of a convex function lies above the graph of 
the function. There are also converses of the Jensen's inequality, which estimate the upper bound of the integral 
of the convex function.</p>

<p>In the context of probability theory, it is generally stated in the following form: if $X$ is a random variable   
and $\phi$ is a convex function, then</br>
<center>$\phi(E[X]) \leq E[\phi(X)]$.</center>
For a real convex function $\phi$ , numbers $x1, x2, ..., xn$ in its domain, and positive 
weights $ai$, Jensen's inequality can be stated as:</br>
<center>$\phi(\frac{\sum a_{i} x_{i}}{\sum a_{j}}) \leq \frac{a_{i}\phi (x_{i})}{\sum a_{j}}$.</center>

<h3>(3)The Log Sum Inequality</h3>
Notice that after setting $f(x) = xlog x$ we have</br>
<center>$\begin{align}
\sum_{i=1}^{n}a_{i}llog\frac{a_{i}}{b_{i}} =& \sum_{i=1}^{n}b_{i}f(\frac{a_{i}}{b_{i}}) = b\sum_{i=1}^{n}\frac{b_{i}}{b}f(\frac{a_{i}}{b_{i}}) \\
\geq & bf(\sum_{i=1}^{n}\frac{b_{i}}{b}\frac{a_{i}}{b_{i}}) = bf(\frac{1}{b}\sum_{i=1}^{n}a_{i}) = bf(\frac{a}{b})\\
= & alog \frac{a}{b}
\end{align}$.</center>

where the inequality follows from Jensen's inequality since  $\frac{b_{i}}{b} \geq 0, \sum _{i} \frac{b_{i}}{b} = 1$, 
and $f$ is convex.

<h2>3.Application</h2>
<p>The log sum inequality can be used to prove several inequalities in information theory such as Gibbs' inequality or 
the convexity of Kullback-Leibler divergence.</p>

<p>For example to prove Gibbs' inequality it is enough to substitute $p_{i}$s for $a_{i}$s, and $q_{i}$s for $b_{i}$s to get</br>
<center>$D_{KL}(P\parallel Q) \equiv \sum_{i=1}^{n}p_{i}log_{2}\frac{p_{i}}{q_{i}} \geq 1log\frac{1}{1} = 0$.</center>
</p>

<h2>References</h2>
<p>[1]Convex function, http://en.wikipedia.org/wiki/Convex_function</br>
[2]Jensen's inequality, http://en.wikipedia.org/wiki/Jensen%27s_inequality</br>
[3]The Log Sum Inequality, http://en.wikipedia.org/wiki/Log_sum_inequality
</p>


