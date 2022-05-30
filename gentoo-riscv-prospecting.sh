#!/bin/bash

set -x
set -e

eix -# --in-overlay gentoo > pkgs.txt

# test faild: dev-python/typish
#rm -rf 0_riscv.txt 1_arm64.txt 1_arm64_ver.txt 2_none.txt
#./keyworded pkgs.txt

rm -f full.txt
for pkg in $(cat pkgs.txt | grep -Ev '(acct-user|acct-group)' | sort | uniq); do
    if [[ "$(equery -q m $pkg | grep riscv)" ]]; then
        continue
    fi
    dep_pkgs=$(zbt ls -p default/linux/riscv/20.0/rv64gc/lp64d/desktop/plasma/systemd $pkg)
    dep_pkgs_cnt=$(echo "$dep_pkgs" | wc -l)
    dep_pkgs_oneline=$(echo "$dep_pkgs" | tr '\n' ' ')
    eix_info=$(eix -*cp $pkg 2>/dev/null)
    echo -e "$pkg\t$dep_pkgs_cnt\t$eix_info\t$dep_pkgs_oneline" >> full.txt
done

sort -rnk2 -o full.txt full.txt

RE_MASK=
cat full.txt | grep -Ev '(acct-user|acct-group|dev-java|dev-haskell|dev-ros|dev-ml|ros-meta|qtwebengine)' > todo.txt
cat todo.txt | grep -Ev '(^dev-haskell|^dev-perl|^dev-php|^dev-ruby|^app-xemacs|^sci-biology|OpenStack)'  > todo2.txt

git add gentoo-riscv-prospecting.sh 0_riscv.txt 1_arm64.txt 1_arm64_ver.txt 2_none.txt pkgs.txt full.txt todo.txt todo2.txt
git commit -m "update $(date '+%F %H:%M')"
git push
