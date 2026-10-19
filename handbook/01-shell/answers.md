# Linux and shell answers

The main drive in `README.md` creates every artifact the grader inspects. The planted fault changes only `/tmp/handbook-shell/owned.txt` from mode `640` to `600`.

Inspect it from the repository root:

```sh
stat -c '%a %U %G %n' /tmp/handbook-shell/owned.txt
```

Repair it from the repository root:

```sh
chmod 640 /tmp/handbook-shell/owned.txt
```

Grade from `handbook/01-shell`:

```sh
sh ./check.sh
```
