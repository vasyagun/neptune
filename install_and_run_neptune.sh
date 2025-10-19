#!/usr/bin/env bash
set -euo pipefail

# -------- settings you can tweak (optional) --------
ARCHIVE_URL="${ARCHIVE_URL:-https://github.com/giks89/test_assets/releases/download/npt/neptune-hiveos.0.7.0.tar.gz}"
ARCHIVE_NAME="${ARCHIVE_NAME:-neptune-hiveos.0.7.0.tar.gz}"
SESSION_NAME="${SESSION_NAME:-npt}"
POOL_URL="${POOL_URL:-stratum+ssl://eu.poolhub.io:4444}"
WORKER_NAME="${WORKER_NAME:-TEST1}"

# -------- helpers --------
have() { command -v "$1" >/dev/null 2>&1; }
as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif have sudo; then
    sudo "$@"
  else
    echo "Этот скрипт устанавливает пакеты через apt и требует root или sudo." >&2
    exit 1
  fi
}

# -------- 1) deps --------
if have apt-get; then
  echo "[*] Обновляю списки пакетов и устанавливаю зависимости…"
  as_root apt-get update -y
  as_root apt-get install -y ca-certificates curl gnupg nano screen wget tar
else
  echo "[!] apt-get не найден. Этот скрипт рассчитан на Debian/Ubuntu." >&2
  exit 1
fi

# -------- 2) download --------
if [ ! -f "$ARCHIVE_NAME" ]; then
  echo "[*] Скачиваю архив: $ARCHIVE_URL"
  wget -O "$ARCHIVE_NAME" "$ARCHIVE_URL"
else
  echo "[*] Архив уже есть: $ARCHIVE_NAME (пропускаю загрузку)"
fi

# -------- 3) extract --------
echo "[*] Распаковываю архив…"
tar xzf "$ARCHIVE_NAME"

# Папка должна называться 'neptune' по вашим шагам
if [ ! -d neptune ]; then
  echo "[!] Папка 'neptune' не найдена после распаковки." >&2
  exit 1
fi
cd neptune

# -------- 4) perms --------
if [ -f ./neptune ]; then
  chmod +x ./neptune
else
  echo "[!] Бинарник './neptune' не найден." >&2
  exit 1
fi

# -------- 5) write config.json --------
echo "[*] Создаю config.json…"
cat > config.json <<'JSON'
{
  "selected": [
    "neptune-gpu"
  ],
  "algo_list": [
    {
      "id": "neptune-gpu",
      "algo": "neptune",
      "pool": "stratum+ssl://eu.poolhub.io:4444",
      "worker_name": "TEST1",
      "address": "nolgam1f09t0ln38ceymrkpjv03jlqhnyufl0kzddq74xjg3xu24ppsc8ap837e5022pxgkxxgmwtxldf8vkg7z23c0g54w2sugvmt4f5mvkykcgv9t0z6qpe9nkxrz5mtygu8q73wpwavfqt9d6xgxcmmj5ypzkmultt4euk9m7t4cg0usk9mpr03qdlqj29fy2tj405he08ettfsmcmg25evftfredh2f2grpvq2fgx2l3u7zr53k6e6cw2rw6d7tj4vwmhjecuwj7lucc9v6uky2m4x4jlupzstf93je7ejramlqdnxaa9zan2alrm5v0en0wp8ayx8jtv96c3xxqxnlc4fhf6rev8e340hmmkjal5ht2muvpglux3hhwmvhl0h39k3d0gedkp39f9ry3g8ylmxzydf6995mu67ppt76vq2v3776qmhzvhh8kqk38umqx24rnzzkmjm3ptsa86mx4gmfe65cm3v7963404h2zvztnff6xyryxqa9x9cl5gjl5fzhmlr4ygp044xy77ww937nyew0r8cgr5gvdcsz9fcgtgkgqg73vx5209h0p7942k0tvvnre6544dx65qs6pane67a8gtj8fzuy6yntj0fnen39heffrffag74vyga6726fprdnxnj994gjg477jkm6h6uu9jkhkgvxv9dzcckse4q07fvcv8dqshsuuusj6ucssygggctqfxfxrhvqksqvhz8t4w2a5ns8x2s2syrn6nhtycgu0d72x4hwt4l3aqd8rqq7d76pm2tr04hc6shm0fudnxhvjzqcq7d9u5t9eyj77ghxf8aspyqj47fuskvadn36szz2nhd4xz33e7eukrksppsehpvgcpvmcwaufwz7ql7g63tm2lz8wewu94y2568w5palpyqnvhuq5msmf8hwu0rwfz58scdrsycwdu56sqznh08ayzkgw2lynhtlmed399ecmc59t6krtkn2rhllz6szxknpm70c4wq3eqhp9kle4vsjwdh6yt3avww55cy4c2fslsxg4teuv5yym4ps3ctcmz0ekd0nvqztgcsagenqmqqscnchz0nvhny847nmhqwaqp3u03r6nkkwg4a40878jawrng3r3dec3txpvgk3dhgrayyyx28nte2nf9phhhejd6gxn07jdkvejhmrcfa36fupasg3rhc3cd0q474uh9lhkum8k2yesgw08h29mcgzzdlk9y78l9nqd62ruwva6acn8xfva2r7alt3qa4ypn8kf28uqywd042csy4v033ta9sz7jkg9fn58cuh9r3vjp2xfcj958n7wreyxk0cnkvgw2fycq4a46vd5karz3w0h7al46xtgtekfrcg4eu0920guflas5k0elhz0ccraqctvar9u94287dclqz33sm7xejx0djf8ztrgfw5xa9p32dmq669k8a2geze6vdynnfzelvz0eg6yuzwfaq07z4gz80pl2lm7p2aqxu954emkvmnsalzlu5mygyk9zatd9cu4rsstn9jjrelluywnnq0au9unljdef384zuhy95xj3g6k3urkugzfr87gczs2dtd3epxwzs4rs6qdrl8js3zu7529g6xct6xcdka4s8he6gyqylwxwl2wpvkfn262s7ms8pq0p9lg8n47dtp9nqq59esq7hkplm7s6qhzzwumrm6d7d94hq7w4rxr8pfaa7vndfcu8qd869w0yyhylw4sgykp990rs4hxq8qe7pfgk4syr0rqzv4e7wy6hje50fece8tketz8s7e93gv3t9svwd45mmvkpz7q0tfua3qpwsxruy3xdjm98vfy3asrpumkspweqclx6rlcq92venwz4zvmn2lq04r4h6rkf0ush3usgvpvfg473pq72juhfh3f35xt8jde5wnzz32c40qdur082gz4hzy4u90swdyakpw3jatfl7axfr8ndpjlgx8wlueqejvxgtdnt50073ut07shkfn55p4dwwywaq5azdm3ka83expurfwtujpup8kuujass69zyafklw4may4w79uzx9jvn549gd8w56lkuuwjdszaaa2r67rh4ycfkfdwd70q5r5ayzk0qx7yw67pvfdddrarqtttm6jdh283pz2w2gydezz3a9dz0qjtv9q3ftf4dy7t4scu3r7kq0csrwu2vnwxsekcyq57awjh0y7t65uzl5f2puufyx2py05kskxmlfgwxz9xp8vaq2cmjs24ped88qw2ya2m65thyjme6x976gr34es4xg2crtl6em79f4fnvamuvfxezvlaaw242d8qjdfsq98hp993f0x6jpyran0a744vyane9kzynrs0mwk3x79wr5myal4eq2dpqtam39u3k79uja5wste8pvnmdezltmc4jglchqh0hzpnh4mcx358t3rl96gd5evfxdp4sr87cz2kehgn4s8cjzdkzszqesy0p6vv2gtjkulsrrzpddpf7ucue43dz723l093rgwn0l9uz9khsspm4mtr9x5nd4k4vssj65x3wtwa0924pz75c8009arwz5he0905x6uuddfj3fgd6hmfzpzslzautjdtt5x4f7dhls8pjxwaa4syzhq9jxlkuzktsn94z4t3yntgm70p353tnp9ke9knp58eklsmgcl3syvsd09tm2x4fq00z4lylpsfkvf7e4wnhpj6fv2p3xhpn8jdlye8n0v56f20pgjml8gc826nnhsp3rfdgculhrr7ezp4sqlssamjw0kjxezlqqcaa8v405aefl6ffhnpqppv3ap4wp8sxg3r6h62tscmujy937dxt6e2mns90fdmyy6ky0zj0j3xx8nulswnczp7pfzseexzthtxah3lgs50myjwva5tudmglv3kjs3zwkxt0e8l3cw7wnyhs78urwq6sr6q3v3m3e329je79l0mm6yemvddv0gpvclxahaf9jppjreucx3x6n77kc0sa8sx2uf5dlthwvexey86lusxgdx48cse0r66fdye8tpeue40q6xv55v2jzqtphtqzmv8pkadu0yrll7gmz8djcgal99urlzjg2wtdztu79r95tsv6wxqv5424cvvv2hhdv25ys50hutrcj3455sca6qdd6eje9f8kmr30060nlswn5kpx5q7mvwl0pe8yeqnw4z8ah8dr99352f7q7zczcw92afsnd8xald3xmvj4j82nhx4fcg45w9c0vkmvapw3cfvqy5dxtw98l3lnhrs39m665mu549ydp4lrc29ufm55zsxrdk4c7yvw6afsqgyu9mt8js2c3qxscuupy8n44g6vzecye4rujmnhh5uhkdyppcxu7warcea79qvjxz4fvvevu7h8chukcc4hhdquwugm755evqzdel74ctxrvk7vyygaemnywjr6ajzaw8snhwr6as2cg852llw3eek783l8v",
      "config": {
        "type": "gpu",
        "option": "all"
      },
      "idle_algos": []
    }
  ]
}
JSON

# Подставим переменные POOL_URL и WORKER_NAME в уже созданный файл (если вы меняли их сверху)
jq_installed=false
if have jq; then jq_installed=true; fi

if $jq_installed; then
  tmpcfg="$(mktemp)"
  jq --arg pool "$POOL_URL" --arg worker "$WORKER_NAME" \
     '.algo_list[0].pool = $pool | .algo_list[0].worker_name = $worker' \
     config.json > "$tmpcfg" && mv "$tmpcfg" config.json
else
  # Без jq — на всякий случай просто предупредим
  echo "[i] jq не установлен, оставляю pool/worker из шаблона. Можно установить: sudo apt-get install -y jq"
fi

echo "[*] Итоговый config.json:"
head -n 40 config.json || true
echo "… (файл длинный, показаны первые строки)"

# -------- 6–7) run in screen --------
echo "[*] Запускаю майнер в screen-сессии '${SESSION_NAME}'…"

# Если сессия уже есть — не создаём вторую
if screen -list | grep -q "\.${SESSION_NAME}"; then
  echo "[i] screen-сессия '${SESSION_NAME}' уже существует. Новую не запускаю."
else
  screen -S "${SESSION_NAME}" -dm bash -lc "./neptune run --config config.json"
fi

echo
echo "Готово!"
echo "› Проверить работу:    screen -r ${SESSION_NAME}"
echo "› Отсоединиться:       Ctrl+A затем D"
echo "› Остановить майнер:   screen -S ${SESSION_NAME} -X quit"
