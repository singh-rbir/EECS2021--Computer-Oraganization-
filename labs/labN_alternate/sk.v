module sk(upper, lower, a, b, c, d);
output upper, lower;
input a,b,c,d;

or (upper, a, b, c, d);
not (notC, c);
xor (lower, a, b, notC, d);

endmodule

