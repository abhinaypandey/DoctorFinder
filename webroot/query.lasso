[
database_initialize
content_type('application/json')
include('dbconn.lasso');
local(sql)
local(json=map)
local(dataMap=map)

local(citykey = web_request->param('citykey'))
local(city = web_request->param('city'))
local(state = web_request->param('state'))
local(zip = web_request->param('zipcode')) 
local(zipkey = web_request->param('zipkey')) 
local(sp = web_request->param('doctor'))
local(start = web_request->param('start'))
local(records = web_request->param('records'))
local(radius = web_request->param('radius'))

local(zips=web_request -> param('zips'))
local(ziplist=array)


if(#zips->size !=0)
  #sql ='SELECT latitude ,longitude  FROM zip WHERE zip.id='+encode_sql(#zips)
  var('latitude');
  var('longitude');
  var('ziparray'='(')
  inline(
  -host=($czip),
  
  -database='docfinder',
  -sql=#sql
  
  ) => {^
      $latitude=field('latitude')
      $longitude=field('longitude')
      
  ^}
  
  #sql= "SELECT id, ( 3959 * acos( cos( radians("+ $latitude + ") ) * cos( radians( latitude ) ) * cos( radians( longitude) - radians("+ $longitude + ") ) + sin( radians("+ $latitude + ") ) * sin( radians( latitude ) ) ) ) AS distance FROM zip HAVING distance < "+#radius+" ORDER BY distance ASC; "
  
  inline(
  -host=($czip),
  
  -database='docfinder',
  -sql=#sql
  
  ) => {^
  
      #ziplist=Records_Array
      #ziplist->foreach=>{^
        $ziparray+=#1->get(1)+','
      ^}
      $ziparray=$ziparray+'0)'
        
  ^}
  
  #sql = 'SELECT * FROM doctor INNER JOIN address ON doctor.address_id = address.id INNER JOIN zip ON zip.id = address.zip_id WHERE zip.id in '+$ziparray
  inline(
  -host=($czip),
  -database='docfinder',
  -sql=#sql
  
  ) => {^
      
    #dataMap=Records_Map
  ^}
  
  

else(#zip->size!=0)
  #sql = 'SELECT * FROM docdb WHERE zip.id ='+encode_sql(#zip)
  inline(
  -host=($czip),
  
  -database='docfinder',
  -sql=#sql
  
  ) => {^
    #dataMap=Records_Map
  ^}
  
else(#city->size!=0 && #state->size!=0)
  #sql = 'SELECT * FROM doctor INNER JOIN address ON doctor.address_id = address.id WHERE address.city="' +#city+'" AND address.state="'+#state+'"'
  inline(
  -host=($czip),
  
  -database='docfinder',
  -sql=#sql
  
  ) => {^
    #dataMap=Records_Map
  ^}
  
else(#citykey->size!=0)
  #sql = 'SELECT city,state FROM address WHERE city LIKE "%' +#citykey+'%"'
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