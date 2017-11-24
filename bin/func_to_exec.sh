## -*- sh -*-

set -e ## Die on errors

if [[ "$(pwd)" =~ functions ]] || \
       [[ "$(pwd)" =~ bin ]]
then
    echo 'Cannot be in functions or bin subdir for conversion.'
    echo 'cd .. and re-exec.'
    exit 1
fi

## Find sources, set targets
src_paths="$@"
bad=0
for i in $src_paths
do
    if [ ! -r $i ]
    then
        echo "$i not found"
        ((bad+=1))
    fi
    file=$(basename $i)
    files="$files $file"
    tgt_paths="$tgt_paths bin/$file"
done
[ -z "$tgt_paths" ] && echo "no sources found to convert" && exit 1
((bad)) && echo "some sources bad. bailing" && exit 1

echo git mv $src_paths bin
git mv $src_paths bin
echo "git commit $src_paths -m 'func to exec, mv (delete) phase'"
git commit $src_paths -m 'func to exec, mv (delete) phase'
echo "git commit $tgt_paths -m 'func to exec, mv (create) phase'"
git commit $tgt_paths -m 'func to exec, mv (create) phase'

echo func_to_exec.pl $tgt_paths
func_to_exec.pl $tgt_paths

rm -f commit_list   ## a file holding the functions we chose to commit after conversion
for i in $tgt_paths
do
    resp=''
    diff -w $i ${i}.new && true ## so that a diff does not trigger an exit due
                                ## to the -e setting
    resp=$(yesno "mv ${i}.new $i")
    if [ "$resp" = 'y' ]
    then
        mv ${i}.new $i
        chmod +x $i
        echo $i >> commit_list
    fi
done

if [ -s commit_list ]
then
    echo "git commit $(cat commit_list) -m 'func to exec, convert phase'"
    git commit $(cat commit_list) -m 'func to exec, convert phase'
else
    echo nothing to commit after convert phase
fi
