module main

import net.urllib
import os
import rand
import strings
import time
import vweb

const port = ((os.getenv_opt('PORT') or { '8080' }).int())

struct Item {
	id      string
	details string
mut:
	done bool
}

struct App {
	vweb.Context
mut:
	state shared State
}

struct State {
mut:
	items map[string]Item
}

fn main() {
	initialise_database()

	mut app := &App{
		state: State{
			items: read_database()
		}
	}

	os.chdir(os.dir(os.executable()))?

	app.handle_static('js', false)
	app.handle_static('css', false)

	app.serve_static('/items.csv', 'data/items.csv')

	vweb.run(app, port)
}

fn (mut app App) get_content() string {
	rlock app.state {
		mut incomplete := []string{cap: app.state.items.len}
		mut complete := []string{cap: app.state.items.len}

		for id, item in app.state.items {
			mut content := strings.new_builder(100)
			content.write_string('<li><label ')

			// htmx configuration for the label+checkbox
			content.write_string('hx-target="#main-list" ')
			content.write_string('hx-trigger="click" ')
			content.write_string('hx-post="/setitem/$id" ')
			content.write_string('hx-swap="outerHTML">')

			// The checkbox inside the label
			content.write_string('<input type="checkbox" name="item-${id:03}"')
			if item.done {
				content.write_string(' checked')
			}
			content.write_string('/>')

			// The text of the item
			if item.done {
				content.write_string('<del>')
			}
			content.write_string(item.details)
			if item.done {
				content.write_string('</del>')
			}

			content.write_string('</label></li>')

			if item.done {
				complete << content.str()
			} else {
				incomplete << content.str()
			}
		}
		mut content := strings.new_builder(100 * app.state.items.len)
		for item in incomplete {
			content.write_string(item)
		}
		for item in complete {
			content.write_string(item)
		}
		return '<ul id="main-list">$content</ul>'
	}
	return '<ul id="main-list"></ul>'
}

['/']
fn (mut app App) index() vweb.Result {
	content_list := app.get_content()
	year := time.now().year
	html_content := $tmpl('templates/index.html')
	return app.html(html_content)
}

['/setitem/:id'; post]
fn (mut app App) update_item(id string) vweb.Result {
	app.toggle_item(id)
	return app.html(app.get_content())
}

fn (mut app App) toggle_item(id string) {
	lock app.state {
		if id in app.state.items {
			app.state.items[id].done = !app.state.items[id].done
		}
	}
	app.flush_state()
}

['/additem'; post]
fn (mut app App) add_item() vweb.Result {
	input := urllib.path_unescape(app.req.data) or { return app.html(app.get_content()) }
	details := input[9..]
	lock app.state {
		// Generate a new unique id
		mut new_id := rand.uuid_v4()
		for ; new_id in app.state.items; {
			new_id = rand.uuid_v4()
		}

		app.state.items[new_id] = Item{
			details: details
			done: false
		}
	}
	app.flush_state()
	return app.html(app.get_content())
}

fn (mut app App) flush_state() {
	rlock app.state {
		write_database(app.state.items)
	}
}
