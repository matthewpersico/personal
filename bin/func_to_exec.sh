## -*- sh -*-

src_paths="$@"
for i in $src_paths
do
    file=$(basename $i)
    files="$files $file"
    tgt_paths="$tgt_paths bin/$file"
done

rm committem     ## a file holding the functions we chose to commit after conversion
git mv $src_paths bin
git commit $src_paths -m 'func to exec, mv phase'
git commit $tgt_paths -m 'func to exec, mv phase'
./bin/func_to_exec.pl $tgt_paths
for i in $tgt_paths
do
    diff -w $i ${i}.new
    resp=$(yesno "mv ${i}.new $i")
    [ "$resp" = 'y' ] && mv ${i}.new $i && echo $i >> committem
done
git commit $(cat committem) -m 'func to exec, convert phase'
