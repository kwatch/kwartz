<?php
	// class definition
	class User {
		var $name;
		var $mail;
		
		function User($name, $mail) {
			$this->name = $name;
			$this->mail = $mail;
		}
	}

	// set user list
	$user_list = array();
	$user_list[] = new User('sumire', 'violet@mail.com');
	$user_list[] = new User('nana',   'seven@mail.org');
	$user_list[] = new User('momoko', 'peach@mail.net');
	$user_list[] = new User('kasumi', 'mist@mail.gov');
	
	// display
	include('border1.view');
?>