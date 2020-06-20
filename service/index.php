<?php
class API {

	private $dbh;
	private $response;
	private $allowOrigin;
	private $queries = [
		'songs' => 'SELECT songs.*, projects.slug AS project_slug, projects.title AS project_title, media.path AS image FROM songs '.
				 'LEFT JOIN projects ON songs.project_id = projects.id '.
				 'LEFT JOIN media ON songs.media_id = media.id',
		'projects' => 'SELECT projects.*, media.path AS image FROM projects LEFT OUTER JOIN media ON projects.media_id = media.id'
	];

	public function __construct() {
		$this->response = new stdClass();
		$this->response->status = 200;
		$this->response->message = 'OK';
		$this->response->data = [];

		$this->config();
		$this->getRoute();
	}

	private function config() {
		switch ($_SERVER['HTTP_HOST']) {
			case 'archive-api.trentj.org':
				$database = array(
					'host' => 'db.trentjohnson.com',
					'username' => 'xxxxxx',
					'password' => 'xxxxxx',
					'database' => 'archive_audio'
				);
				$this->allowOrigin = 'https://archive.trentj.org';
			break;

			default:
				$database = array(
					'host' => 'localhost',
					'username' => 'archive_user',
					'password' => 'archive_user',
					'database' => 'archive_audio'
				);
				$this->allowOrigin = '*';
			break;
		}

		try {
			$this->dbh = new PDO(
				"mysql:host={$database['host']};dbname={$database['database']}",
				$database['username'],
				$database['password'],
				array(PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8")
			);

		} catch(PDOException $e) {
			print $e->getMessage(); exit;
		}
	}

	private function getRoute() {
		$url = parse_url($_SERVER['REQUEST_URI']);
		[$root, $type, $id] = explode('/', $url['path']);

		switch ($type) {
			case 'featured':
				$this->response->data = $this->getFeatured();
			break;
			case 'projects':
				$this->response->data = $this->getProjects($id);
			break;
			case 'songs':
				$this->response->data = $this->getSongs($id);
			break;
			case 'collections':
				$this->response->data = $this->getCollections($id);
			break;
			case 'save-project':
				$this->response->data = $this->saveProject();
			break;
			case 'songs-admin':
				$this->response->data = $this->getsongsAdmin();
			break;
			default:
				$this->response->status = 404;
				$this->response->message = 'Invalid route';
			break;
		}

		header('Access-Control-Allow-Origin: '. $this->allowOrigin);
		header('Access-Control-Allow-Headers: *');
		header('Cache-Control: no-cache, must-revalidate');
		header('Expires: Mon, 22 Mar 1971 02:30:00 GMT');
		header('Content-type: application/json');

		// http_response_code($this->response->status);
		echo(json_encode($this->response, JSON_NUMERIC_CHECK));
	}

	private function getFeatured() {
		$result = [];
		$result['projects'] = $this->getProjects('featured');
		$result['songs'] = $this->getSongs('featured');

		return $result;
	}

	private function getProjects($id) {
		$sql = $this->queries['projects'];

		if ($id) {
			if ($id == 'featured') {
				$sql .= ' WHERE projects.featured IS NOT NULL';
			} else {
				$sql .= $this->quoteInto(' WHERE projects.slug=?', $id);
			}
		}

		$result = $this->execute($sql);

		if ($result && $id) {
			$songs = $this->getProjectSongs($result[0]['id']);
			$result[0]['songs'] = $songs;
		}
		return (count($result) > 1 || $id == 'featured') ? $result : $result[0];
	}

	private function getProjectSongs($id) {
		$sql = $this->queries['songs'];

		$sql .= $this->quoteInto(' WHERE project_id=?', $id);
		$result = $this->execute($sql);

		return $result;
	}

	private function getSongs($id = null) {
		$sql = $this->queries['songs'];

		if ($id) {
			if ($id == 'featured') {
				$sql .= ' WHERE songs.featured IS NOT NULL';

			} else {
				if (is_numeric($id)) {
					$sql .= $this->quoteInto(' WHERE songs.id=?', $id);

				} else {
					$sql .= $this->quoteInto(' WHERE songs.slug=?', $id);
				}
			}
		}

		$result = $this->execute($sql);
		return (count($result) > 1 || $id == 'featured') ? $result : $result[0];
	}

	private function getParentSongs() {
		$sql = 'SELECT * FROM parent_songs ORDER BY title DESC';
		$result = $this->execute($sql);
		return $result;
	}

	private function getCollections($project_id) {
		$sql = $this->quoteInto('SELECT * FROM collections WHERE project_id=?', $project_id);
		$collections = $this->execute($sql);

		// SELECT songs.* FROM collection_map
		// 	LEFT JOIN songs ON collection_map.song_id = songs.id
		// 	WHERE collection_id = 1
		// 	ORDER BY ordinal asc

		for ($i=0; $i<count($collections); $i++) {
			$sql = $this->quoteInto('SELECT songs.* FROM collection_map LEFT JOIN songs ON collection_map.song_id = songs.id WHERE collection_id=? ORDER BY ordinal ASC', $collections[$i]['id']);
			$collections[$i]['songs'] = $this->execute($sql);
		}

		return $collections;
	}















	/* ----- ADMIN ----- */

	// return minimal project data for admin drop-down
	private function getProjectsList() {
		$sql = 'SELECT id, title FROM projects ORDER BY title ASC';
		$result = $this->execute($sql);
		return $result;
	}

	private function getParentSongsList() {
		$sql = 'SELECT id, title FROM parent_songs ORDER BY title DESC';
		$result = $this->execute($sql);
		return $result;
	}

	private function getSongsAdmin() {
		$result = [];
		$result['songs'] = $this->getSongs();
		$result['projects_list'] = $this->getProjectsList();
		$result['parents_list'] = $this->getParentSongsList();
		return $result;
	}

	private function saveProject() {
		if (count($_POST) == 0) return false;

		$data = $_POST;

		if (count($_FILES)) {
			$data['media_id'] = $this->newMediaItem($_FILES['banner'], 'image');
		}

		if ($data['id']) {
			// update based on id
			$sql = $this->getUpdateString('projects', $data, $data['id']);

		} else {
			// insert new project
			$sql = $this->getInsertString('projects', $data);
		}

		$result = $this->execute($sql);
		$result['sql'] = $sql;
		$result['id'] = $media_id;
		return $result;
	}

	// todo: implement type in case this later supports video, for example
	private function newMediaItem($file, $type) {
		$target_dir = 'uploads/images/';
		$target_file = $target_dir . basename($file['name']);

		if (move_uploaded_file($file['tmp_name'], $target_file)) {
			// insert a new media row and add the media_id to the project insert/update below
			$data = [
				'path' => $file['name'],
				'type' => $type
			];

			$sql = $this->getInsertString('media', $data);
			$result = $this->execute($sql);

			return $this->dbh->lastInsertId();
		}

		// todo: configure an error routine
		return 'error';
	}













	/**
	 * Replace the ? in a string with the specified value.
	 * @param string $subject The string containing the ?
	 * @param string|integer $value The value to insert into the subject.
	 */
	private function quoteInto($subject, $value) {
		$value = addslashes($value);
		return str_replace('?', "'$value'", $subject);
	}

	private function nullIfEmpty($value) {
		if ($value) return $value;
		return 'NULL';
	}
	
	/**
	 * Takes the array and returns a comma separated list of pairs
	 * column1=value1, column2='value2' ...etc
	 */
	private function getUpdateString($table, $arr, $id) {
		$pairs = [];

		foreach ($arr as $key=>$value) {
			// don't add the primary key as it can't be updated
			if ($key == 'id') {
				continue;
			}

			if (is_numeric($value)) {
				$value = $this->nullIfEmpty($value);

			} else {
				$value =  $this->quoteInto('?', $value);
			}

			array_push($pairs, $key .'='. $value);
		}

		return "UPDATE $table SET ". implode(',', $pairs) ." WHERE id=". $this->quoteInto('?', $id);
	}

	private function getInsertString($table, $arr) {
		$cols = [];
		$vals = [];

		foreach ($arr as $key=>$value) {
			array_push($cols, $key);

			if (is_numeric($value)) {
				array_push($vals, $this->nullIfEmpty($value));
			} else {
				array_push($vals, $this->quoteInto('?', $value));
			}
		}

		return "INSERT INTO $table (". implode(',', $cols) .") VALUES (". implode(',', $vals) .")";
	}

	protected function execute($sql) {
		if ($this->dbh) {
			$sth = $this->dbh->prepare($sql);

			if ($sth->execute()) {
				return $sth->fetchAll(PDO::FETCH_ASSOC);

			} else {
				$error = $sth->errorInfo();
				//Application::Exception($error[2].'<br>'.$this->statement);
				return false;
			}
		} else {
			//Application::Exception('Not connected to database.');
			return false;
		}
	}


	public function __destruct() {
		$this->dbh = null;
	}

}

$api = new API();

?>