javascript:(function(){function R(w){try{var d=w.document,j,i,t,T,N,b,r=1,C;for(j=0;t=[%22object%22,%22embed%22,%22applet%22,%22iframe%22][j];++j){T=d.getElementsByTagName(t);for(i=T.length-1;(i+1)&&(N=T[i]);--i)if(j!=3||!R((C=N.contentWindow)?C:N.contentDocument.defaultView)){b=d.createElement(%22div%22);b.style.width=N.width; b.style.height=N.height;b.innerHTML=%22<del>%22+(j==3?%22third-party %22+t:t)+%22</del>%22;N.parentNode.replaceChild(b,N);}}}catch(E){r=0}return r}R(self);var i,x;for(i=0;x=frames[i];++i)R(x)})()