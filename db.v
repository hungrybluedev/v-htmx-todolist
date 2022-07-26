module main

import os
import encoding.csv

const (
	database_file = 'data/items.csv'
	initial_cap   = 128
)

fn initialise_database() {
	os.mkdir('data') or {}
	if !os.exists(database_file) {
		write_database({
			'3a712780-d0b1-492d-883a-6fb467ddc8c1': Item{
				id: '3a712780-d0b1-492d-883a-6fb467ddc8c1'
				details: 'Buy Milk'
				done: false
			}
			'5b1cd038-b044-497f-a0ed-5b19e817454b': Item{
				id: '5b1cd038-b044-497f-a0ed-5b19e817454b'
				details: 'Buy Eggs'
				done: false
			}
			'f34a97b5-c40a-46d7-9fce-0277fffd2adc': Item{
				id: 'f34a97b5-c40a-46d7-9fce-0277fffd2adc'
				details: 'Buy Pens'
				done: true
			}
		})
	}
}

fn read_database() map[string]Item {
	file_contents := os.read_file(database_file) or { return {} }

	mut items := map[string]Item{}
	mut reader := csv.new_reader(file_contents)

	// Skip the header row
	reader.read() or {}

	for {
		row := reader.read() or { break }
		id := row[0]
		details := row[1]
		done := row[2] == 'Y'
		items[id] = Item{id, details, done}
	}
	return items
}

fn write_database(items map[string]Item) {
	mut writer := csv.new_writer()

	// Write the header row
	writer.write(['ID', 'Details', 'Done']) or {}

	for id, item in items {
		writer.write([id.str(), item.details, if item.done {
			'Y'
		} else {
			'N'
		}]) or {}
	}

	os.write_file(database_file, writer.str()) or {}
}
