module redis

fn should_retry(err IError) bool {
	return true
}
