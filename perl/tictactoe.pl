#!/usr/bin/perl -w

@F=(1,0,8);@G=(15)x64;@G[0,1,2,3,4,8,16,24,32]=(0..8);@K=(768
,16,4096,1<<24,0,256,64,1<<28,0,64,1<<16,1<<20,4096,1<<16,4<<
20,0);$P=0;for$a(0..15) {for$b(0..3){$C[$a][$b]=$a*4+$b;$C[$a
+16][$b]=$a+4*$b+3*($a&12);$C[$a+32][$b]=$a+16*$b;}}for$a(0..
3){for$b(0..3){$C[$a+48][$b]=16*$a+5*$b; $C[$a+52][$b]=16*$a+
3*$b+3;$C[$a+56][$b]=$a+20*$b;$C[$a+60][$b]=$a+12*$b+12;$C[$a
+64][$b]=4*$a+17*$b; $C[$a+68][$b]=4*$a+15*$b+3;}}for$a(0..3)
{$C[72][$a]=21*$a; $C[73][$a]=19*$a+3;$C[74][$a]=13*$a+12;$C[
75][$a]=11*$a+15;}for$a(0..63){$D[$a][0]=0;} for$a(0..75){for
$b(0..3){$c=$C[$a][$b]; $d=$D[$c][0]+1;$D[$c][0]=$d;$D[$c][$d
]=$a;}}@A=(0)x64; @E=(0)x76;$O=64;$V=.5<rand;while(1){G();$V?
L():K();$V=1-$V;}exit;sub A{$_[0]<=$_[1]?$_[0]:$_[1]}sub B{$_
[0]>=$_[1]?$_[0]:$_[1]} sub D{($P)=@_;@H=(0)x16;for($i=$D[$P]
[0];$i>=1;$i--) {$a=$D[$P][$i];$b=$G[$E[$a]];$H[$b]++;}$K[12]
*B($H[5]-1,0)+$K[13]*A($H[6],$H[5]); }sub F{($P,$X)=@_;@H=(0)
x16;$s=0;$t=$F[$X+1]; for($i=$D[$P][0];$i>=1;$i--){$a=$D[$P][
$i];$U=$E[$a];$b=$G[$U]; $s=$s+$K[$b];$H[$b]++;next if$U!=$t;
for(0..3){$b=$C[$a][$_];$s+=$L[$b]if$P!=$b; }}$s+=$K[14]*B($H
[6]-1,0) +$K[11]*B($H[2]-1,0)+$K[9] *B($H[1]-1,0)+$K[10]*A($H
[1],$H[2])-$L[$P];} sub G{$z='+'.'-'x13; $z.=$z;$z.="+\n";@q=
qw(O . X);$c=$z;for$a(0..3){ for$b(4*$a..4*$a+3){@a=(4*$b..4*
$b+3); $c.=join"", "| ", (map{"$q[$A[$_]+1]  "}@a),"| ",(map{
sprintf"%2u ",$_}@a),"|\n";}$c.=$z; }print$c;print("$_[0]\n")
,exit if$_[0];}sub J{($P,$X)=@_; G("A draw")unless--$O;$A[$P]
=$X;$t=$F[$X+1];$R=0; for($i=$D[$P][0];$i>=1;$i--){$a=$D[$P][
$i]; $U=$E[$a]+$t; $E[$a]=$U;$R=$X,$S=$a if$U==4*$t;}G(($R>0?
"I":"You")." win at @{$C[$S]}")if$R; }sub K{$L[$_]=$A[$_]?0:D
($_)for(0..63);$Z=-1;$Y=-1E10; for$d(0..63){if(!$A[$d]){$u=F(
$d,1);$Y=$u,$Z=$d if$u>$Y||($u==$Y&&.1>rand); }}J($Z,1);print
"I went at $Z\n"; }sub L{do{print "Go (0..63) "; $P=<STDIN>;}
until($P>=0&&$P<=63&&!$A[$P]);J($P,-1);}#####################
