function trovato = isin (x,a)
%La funzione restituisce il valore 1 se l'elemento x � contenuto almeno una
%volta nel vettore a, 0 altrimenti.
trovato=0;
l=length(a);
i=1;
for i=1:l
    if a(i)==x
        trovato=1;
    end
end
