# To-Do with V + htmx

## Introduction

A sample project written completely with V + htmx.

All the components are server-side rendered and there is no client side
JavaScript, except for htmx. The data is persisted on the server in a
csv file that is also made available through the route: `localhost:PORT/items.csv`.

## Instructions

1. Make sure you have V installed. If not, refer to the
   [V GitHub Page](https://github.com/vlang/v).
2. Clone this repository: `git clone https://github.com/hungrybluedev/v-htmx-todolist.git todolist`.
3. Enter the project directory with `cd todolist`.
4. Run the server with `v run .`.
5. Open the browser and navigate to `localhost:8080`.

If you want to make changes to the V source code and watch the changes,
run `v watch run .`.

In case you update the `templates/index.html` file, you need to restart
the server fully.

If you want to download the current state of the list, navigate to
`localhost:8080/items.csv`

## Deployment

This project has been tested locally. If you want to deploy
this to a server, it is recommended to create an optimised executable:

```
$ v -prod .   <-- this will create an optimised executable
$ ./todolist  <-- the executable
```

Also keep in mind the IO bottleneck and inefficiencies of the app using
a CSV file as its data store.

## Customisation

The port is set to 8080 by default. If you want a different port,
set the PORT environment variable to a valid integer:

```
$ PORT=45000 v run .
# Or
$ v -prod .
$ PORT=13345 ./todolist
```

The database will be initialised on the first run, or every time the
`data` folder is deleted. Check the `initialise_database()` function
in `db.v` for details.

## Support

Made with ❤️ by Subhomoy Haldar ([@hungrybluedev](https://twitter.com/hungrybluedev)).

If you liked this project, consider [sponsoring me](https://github.com/sponsors/hungrybluedev) on GitHub.

## License

This project is distributed under the MIT license.
