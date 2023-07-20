git clone https://github.com/inconshreveable/ngrok.git

# 修改Makefile
bin/go-bindata:
        GOOS="" GOARCH="" go get -u github.com/go-bindata/go-bindata/...

# tls
vi server.conf
[ req ]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = SAN
[ req_distinguished_name ]
countryName                 = Country Name (2 letter code)
countryName_default         = CN
stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = BeiJing
localityName                = Locality Name (eg, city)
localityName_default        = BeiJing
organizationName            = Organization Name (eg, company)
organizationName_default    = Y
commonName                  = Common Name (e.g. server FQDN or YOUR name)
commonName_max              = 64
commonName_default          = 247
[ SAN ]
subjectAltName = DNS:247
subjectAltName = IP:x.x.x.x

openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -config server.conf -extensions SAN
openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt -extfile server.conf -extensions SAN
# openssl x509 -in ./server.crt -noout -text

cp ca.crt ../assets/client/tls/ngrokroot.crt
cp server.crt ../assets/server/tls/snakeoil.crt
cp server.key ../assets/server/tls/snakeoil.key

# 编译ngrok
make release-all

# Server端
./ngrokd -domain 247 -httpAddr "" -httpsAddr "" -tunnelAddr ":9442"

vi /etc/systemd/system/ngrokd.service
[Unit]
Description=Ngrokd Service
After=network.target

[Service]
User=root
WorkingDirectory=/opt/ngrok
ExecStart=/opt/ngrok/ngrokd -domain 247 -httpAddr "" -httpsAddr "" -tunnelAddr ":9442" -log-level "WARNING"

[Install]
WantedBy=multi-user.target


# Client端
vi /etc/hosts
95.169.20.247 247

vi ngrok.cfg
server_addr: 247:9442

./ngrok -config=ngrok.cfg -subdomain "x.x.x" -log stdout -log-level INFO -proto tcp 6609

vi /etc/systemd/system/ngrok.service
[Unit]
Description=Ngrok Service
After=network.target

[Service]
User=root
WorkingDirectory=/opt/ngrok
ExecStart=/opt/ngrok/ngrok -config=/opt/ngrok/ngrok.cfg -subdomain "x.x.x" -log stdout -log-level INFO -proto tcp 6609

[Install]
WantedBy=multi-user.target

