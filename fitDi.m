figure(1);
hist(tmp);
figure(2);
plot(X, pdf(fitdist(tmp, 'exp'), X));
figure(3);
plot(X, pdf(fitdist(tmp, 'weibull'), X));
figure(4);
plot(X, pdf(fitdist(tmp, 'gamma'), X));