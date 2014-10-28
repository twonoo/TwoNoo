Geoip2.configure do |conf|
    # Mandatory
    conf.license_key = 's7OLCfFkkNjF'
    conf.user_id = '94051'

    # Optional
    conf.host = 'geoip.maxmind.com' # Or any host that you would like to work with
    conf.base_path = '/geoip/v2.0' # Or any other version of this API
    conf.parallel_requests = 5 # Or any other amount of parallel requests that you would like to use
end