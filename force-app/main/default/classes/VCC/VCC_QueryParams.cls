public with sharing class VCC_QueryParams {
    public List<VCC_QueryParam> queryParams { get; set; }
    public VCC_QueryParams() {
        this.queryParams = new List<VCC_QueryParam>();
    }

    public String toQueryString() {
        string queryString = '';
        string clause;

        for (VCC_QueryParam queryParam : this.queryParams) {
            if (queryParam.value == null || queryParam.value == '') {
                continue;
            }

            switch on (queryParam.type) {
                when STRINGTYPE {
                    clause = ' = ';
                    queryString += queryParam.field + clause + '\'' + queryParam.value + '\'' + ' AND ';
                }
                when DATETYPE {
                    clause = ' = ';
                    queryString += queryParam.field + clause + queryParam.value + ' AND ';
                }
            }
        }
        return queryString.substring(0, queryString.length() - 4); // chopping off trailing OR condition
    }
}
