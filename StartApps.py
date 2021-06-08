from java.io import FileInputStream

print("*** Trying to Connect.... *****")
connect('weblogic','weblogic123','t3://127.0.0.1:8001')
print("*** Connected *****")

start('config_server')

stopApplication('plato-discovery-service-5.3.0')
startApplication('plato-discovery-service-5.3.0')

start('ac_server')
start('cs_server')
start('ic_server')

disconnect()
exit()

