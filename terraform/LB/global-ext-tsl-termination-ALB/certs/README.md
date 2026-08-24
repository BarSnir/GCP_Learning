# Generate
openssl req -x509 \
  -newkey rsa:2048 \
  -nodes \
  -keyout key.pem \
  -out cert.pem \
  -days 30 \
  -subj "/CN=tls-lab.example.com"

# Check
openssl x509 -in cert.pem -text -noout