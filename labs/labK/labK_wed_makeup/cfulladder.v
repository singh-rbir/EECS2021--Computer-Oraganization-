module cfulladder(S, cout, a, b, cin);

input a, b, cin;

wire my_xor1, my_and1, my_and2, my_not1, my_not2;
output S, cout;

//always
  xor myXor1(my_xor1, a, b);
  not myNot1(my_not1, a);
  and myAnd1(my_and1, my_not1, b);
  xor myXor2(S, my_xor1, cin);
  not myNot2(my_not2, my_xor1);
  and myAnd2(my_and2, cin, my_not2);
  or myOr(cout, my_and1, my_and2);


endmodule
