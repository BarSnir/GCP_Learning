## Commands to execute

### Setting up a HTTP server
```bash
# Switch to the root user to run administrative commands
sudo su

# Apt - Advanced Package Tool (a software management system in Linux)
# Refresh package index
apt update 

# Install the Apache HTTP Server 
# Automatically answer "yes" to all prompts
apt -y install apache2

# Start the Apache2 web server
sudo service apache2 start

## Change Directory to Apache Web Server Root Folder
ls /var/www/html

# Print the text
echo "Hello World!"

# Print the text to a text file
echo "Hello World!" > /var/www/html/index.html

# Show the content for the file
cat /var/www/html/index.html

# Print the host name of vm
echo $(hostname)

# Print the IP address of vm
echo $(hostname -i)

# Print the text containing host name of vm
echo "Hello World from $(hostname)"

# Print the text containing ip and host name of vm
echo "Hello World from $(hostname) $(hostname -i)"

# Write a test message with hostname and internal IP to the web page
echo "Hello world from $(hostname) $(hostname -i)" > /var/www/html/index.html

```

## Startup Script 

[Bootstrapping with VM Startup Script]

```
#!/bin/bash
apt update 
apt -y install apache2
echo "Hello world from $(hostname) $(hostname -I)" > /var/www/html/index.html
```

## Startup Script V2 

[Reducing Launch Time with VM Custom Image]

```
#!/bin/bash
echo "Hello world from $(hostname) $(hostname -I)" > /var/www/html/index.html
service apache2 start
```