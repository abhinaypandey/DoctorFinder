[
database_initialize
content_type('application/json')
include('dbconn.lasso');
local(sql)
local(json=map)
local(dataMap=map)


local(zip = web_request->param('zipcode')) 
local(zipkey = web_request->param('zipkey')) 
local(sp = web_request->param('doctor'))
local(start = web_request->param('start'))
local(records = web_request->param('records'))

  

if(#zip->size!=0)
  #sql = 'SELECT * FROM docdb WHERE zip.id ='+encode_sql(#zip)
  inline(
  -host=($czip),
  -database='docfinder',
  -sql=#sql
  
  ) => {^
    #dataMap=Records_Map
  ^}


  
else(#zipkey->size!=0)
  #sql = 'SELECT distinct zip FROM docdb WHERE zip LIKE "%'+encode_sql(#zipkey)+'%"'
  inline(
  -host=($czip),
  -database='docfinder',
  -sql=#sql
  
  ) => {^
    #dataMap=Records_Map
  ^}
  

else(#sp!='')
    #sql = 'SELECT * FROM docdb WHERE specialization="' +encode_sql(#sp)+'"ORDER BY fname limit '+encode_sql(#start)+','+encode_sql(#records)
    inline(
  -host=($czip),
  -database='docfinder',
  -sql=#sql,
  -maxrecords=350
 ) => {^
    #dataMap=Records_Map
  ^}
/if





#json->insert('data'=#dataMap)
local(xout = json_serialize(#json))
#xout

]