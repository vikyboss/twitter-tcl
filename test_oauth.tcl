#!/usr/bin/env tclsh
#
# this script provides a way to set up and test OAuth authentication.
#

set auto_path [linsert $auto_path 0 [pwd]]

package require oauth
package require twitlib

# output usage information to stdout.
proc ::usage {} {
	global argv0

	puts "Usage: $argv0 <mode> \[arguments\]"
	puts ""
	puts "Mode is one of:"
	puts ""
	puts "  get_pin <consumer key> <consumer secret>"
	puts ""
	puts "    To perform authentication step 1 - get URL to retrieve PIN."
	puts "    You find the consumer key and secret on the Twitter OAuth"
	puts "    clients page."
	puts ""
	puts "  get_token <consumer key> <consumer secret> <token> <token secret> <pin>"
	puts ""
	puts "    to get an access token"
	puts ""
	puts "  get_updates <consumer key> <consumer secret> <token> <token secret>"
	puts ""
	puts "    to test usage of the tokens"
	puts ""
}

# perform authentication step 1 - request authorisation URL to get
# a PIN.
proc ::get_pin {consumer_key consumer_secret} {
	set d [::oauth::get_request_token $consumer_key $consumer_secret]
	foreach key [dict keys $d] {
		set val [dict get $d $key]
		puts "$key = $val"
	}
	puts "You should now authorise the access by going to the authentication"
	puts " URL, and then use it with this script in 'get_token' mode."
	return 1
}

# perform authentication step 2 - use the PIN from step 1 to authenticate.
proc ::get_token {consumer_key consumer_secret token token_secret pin} {
	set d [::oauth::get_access_token $consumer_key $consumer_secret \
		$token $token_secret $pin]
	foreach key [dict keys $d] {
		set val [dict get $d $key]
		puts "$key = $val"
	}
	puts "You should now have sufficient information to perform"
	puts "authenticated requests. Use the above data in the 'get_updates'"
	puts "mode of this script to test this."
	return 1
}

# use authentication information from step 2 to retrieve recent updates.
proc ::get_updates {consumer_key consumer_secret token token_secret} {
	set ::twitlib::oauth_consumer_key $consumer_key
	set ::twitlib::oauth_consumer_secret $consumer_secret
	set ::twitlib::oauth_token $token
	set ::twitlib::oauth_token_secret $token_secret

	set updates [::twitlib::get_unseen_updates]
	foreach status $updates {
		foreach key [dict keys $status] {
			set val [dict get $status $key]
			puts "$key = $val"
		}
	}

	set count [llength $updates]
	puts "Retrieved $count status update(s)."
	return 1
}

# program entry.
# we will exit.
proc ::main {} {
	global argc
	global argv

	if {$argc == 0} {
		::usage
		exit 1
	}

	set mode [lindex $argv 0]

	if {$mode eq "get_pin"} {
		if {[llength $argv] != 3} {
			::usage
			exit 1
		}
		lassign $argv mode consumer_key consumer_secret
		if {![::get_pin $consumer_key $consumer_secret]} {
			exit 1
		}
		exit 0
	}

	if {$mode eq "get_token"} {
		if {[llength $argv] != 6} {
			::usage
			exit 1
		}
		lassign $argv mode consumer_key consumer_secret \
			token token_secret pin
		if {![::get_token $consumer_key $consumer_secret $token $token_secret \
			$pin]} {
			exit 1
		}
		exit 0
 	}

	if {$mode eq "get_updates"} {
		if {[llength $argv] != 5} {
			::usage
			exit 1
		}
		lassign $argv mode consumer_key consumer_secret \
			token token_secret
		if {![::get_updates $consumer_key $consumer_secret $token \
			$token_secret]} {
			exit 1
		}
		exit 0
	}

	::usage
	exit 1
}

::main
