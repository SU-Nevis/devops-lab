# Setup answers

The break removes the local `hello-world:latest` image. Confirm that observation with:

```sh
docker image inspect hello-world:latest
```

Repair and exercise the engine with:

```sh
docker run --rm hello-world
```

Then grade again from `handbook/00-setup`:

```sh
sh ./check.sh
```
