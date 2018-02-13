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
for src_path  in $src_paths
do
    if [ ! -r $src_path ]
    then
        echo "$src_path not found"
        ((bad+=1))
    fi
    file=$(basename $src_path)
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
for tgt_path in $tgt_paths
do
    resp='e' ## Assume we want to edit
    while [ "$resp" = 'e' ]
    do
        diff -w $tgt_path ${tgt_path}.new && true ## so that a diff does not
                                                  ## trigger an exit due to the
                                                  ## -e setting
        resp=$(pick "mv ${tgt_path}.new $tgt_path" "y/n/e" )
        if [ "$resp" = 'y' ]
        then
            mv ${tgt_path}.new $tgt_path
            chmod +x $tgt_path
            echo $tgt_path >> commit_list
        elif [ "$resp" = 'e']
        then
            $EDITOR $tgt_path
        fi
    done
done

if [ -s commit_list ]
then
    echo "git commit $(cat commit_list) -m 'func to exec, convert phase'"
    git commit $(cat commit_list) -m 'func to exec, convert phase'
else
    echo nothing to commit after convert phase
fi
