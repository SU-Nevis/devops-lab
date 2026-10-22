# Linux and shell answers

The main drive in `README.md` creates every artifact the grader inspects. The planted fault changes only `~/devops-lab/01-shell/owned.txt` from mode `640` to `600`.

Inspect it from the repository root:

```sh
stat -c '%a %U %G %n' ~/devops-lab/01-shell/owned.txt
```

Repair it from the repository root:

```sh
chmod 640 ~/devops-lab/01-shell/owned.txt
```

Grade from `handbook/01-shell`:

```sh
./check.sh
```
