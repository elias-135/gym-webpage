var USERS = (function(){

    var expose = {},
        hide = {
            formatWithUnderscores: formatWithUnderscores,
            loadUsersMemberships: loadUsersMemberships,
            printUsers: printUsers,
            showUsers: showUsers
        };

    (function init(){
        showUsers();
    })();

    $(document).on("click",".login-button",Login2JSON);
   
    function Login2JSON() {
		var username = $("#username").val();
		var password = $("#password").val();
		if(username=="" || password==""){
        }else{
		    let data={
				username:username,
				password:password
			};
			let queryString = new URLSearchParams(data).toString();
            loadUsersMemberships(queryString);
        }
        
    }

    function formatWithUnderscores(str){
        return str.replace(/ /g, "_");
    }

    function loadUsersMemberships(payload){
        $("[data-role='browse_user_membership_content'] > section").remove();
        if(window.COFFEE_CONFIG.API_GW_BASE_URL_STR === null){
            $.get("all_users.json", printUsers);
        }else{
            const apiUrl = `${window.COFFEE_CONFIG.API_GW_BASE_URL_STR}/users?${payload}`;
            $.get(apiUrl, printUsers);
        }
    }


    function printUsers(response){
        console.log(response)
        var html_str = '';
        html_str += '<section class="flex-grid">';
        if(response.user_item_arr){
            for(var i_int = 0, o = {}; i_int < response.user_item_arr.length; i_int += 1){
                o = response.user_item_arr[i_int];
                html_str += '<h3>';
                html_str += o.user_name_str;
                html_str += '</h3>'
                for(var j_int = 0; j_int < o.membership_id_arr.length; j_int += 1){
                    html_str += '<div data-product_id="' + o.membership_id_arr[j_int] + '">';
                    html_str += '<h3>';
                    html_str += o.membership_name_arr[j_int];
                    html_str += '</h3>';
                    html_str += '<img src="images/memberships/' + formatWithUnderscores(o.membership_name_arr[j_int]) + '.webp" alt="Image for our ' + o.membership_name_arr[j_int] + '" />';
                    html_str += '</div>';
                }                
            }
        }
        html_str += '</section>';
        
        $("[data-role='user_memberships']").text("");
        $("[data-role='browse_user_membership_content']")
            .append(html_str);
    }


    function showUsers(){
        $("[data-role='users']").text("Fetching Data Users...");
        $("[data-action='show_all']").attr("data-selected", "not_selected");
        $("[data-action='show_vip']").attr("data-selected", "selected");
        loadUsersMemberships();
    }

    return expose;

})();