/singleton/webhook
	var/id
	var/list/urls
	var/mentions

/singleton/webhook/proc/get_message(list/data)
	. = list()

/singleton/webhook/proc/http_post(target_url, payload)
	return // stub

/singleton/webhook/proc/send(list/data)
	var/message = get_message(data)
	if(message)
		if(mentions)
			if(message["content"])
				message["content"] = "[mentions]: [message["content"]]"
			else
				message["content"] = "[mentions]"
		message = json_encode(message)
		. = TRUE
		for(var/target_url in urls)
			var/list/httpresponse = http_post(target_url, message)
			if(!islist(httpresponse))
				. = FALSE
				continue
			switch(httpresponse["status_code"])
				if (200 to 299)
					continue
				if (400 to 599)
					log_debug("Webhooks: HTTP error code while sending to '[target_url]': [httpresponse["status_code"]]. Data: [httpresponse["body"]].")
				else
					log_debug("Webhooks: unknown HTTP code while sending to '[target_url]': [httpresponse["status_code"]]. Data: [httpresponse["body"]].")
			. = FALSE
