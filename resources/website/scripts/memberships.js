var PASTRIES = (function(){

	var expose = {
	
	}, hide = {
		formatWithUnderscores: formatWithUnderscores,
		handleGetAllProducts: handleGetAllProducts,
		loadAllItems: loadAllItems,
		loadItemsByTag: loadItemsByTag,
		printItems: printItems,
		setUpHandlers: setUpHandlers,
		showAll: showAll,
		showPopular: showPopular
	};

	(function init(){
		setUpHandlers();
		showPopular();
	})();

	function formatWithUnderscores(str){
		return str.replace(/ /g, "_");
	}
	function handleGetAllProducts(a, b, c){
		// debugger; //todo
		printItems("todo");
	}

	function loadAllItems(){
		$("[data-role='browse_membership_content'] > section").remove();
		if(window.COFFEE_CONFIG.API_GW_BASE_URL_STR === null){
			$.get("all_memberships.json", printItems);
		}else{
			$.get(window.COFFEE_CONFIG.API_GW_BASE_URL_STR + "/memberships", printItems);
		}
	}

	function loadItemsByTag(){
		$("[data-role='browse_membership_content'] > section").remove();
		var tag_name_str = "popular";
		if(window.COFFEE_CONFIG.API_GW_BASE_URL_STR === null){
			$.get("all_memberships_" + tag_name_str + ".json", printItems);
		}else{
			$.get(window.COFFEE_CONFIG.API_GW_BASE_URL_STR + "/memberships/" + tag_name_str, printItems);
		}
	}

	function printItems(response){
		var html_str = '';
		html_str += '<section class="flex-grid">';
		if(response.membership_item_arr){
			for(var i_int = 0, o = {}; i_int < response.membership_item_arr.length; i_int += 1){
				o = response.membership_item_arr[i_int];
				if (Object.keys(o).length === 0 && o.constructor === Object) {
					break;  // Exit the loop when an empty object is encountered
				}
				html_str += '<div data-product_id="' + o.membership_id_str + '">';
				
				for(var k_int = 0; k_int < o.tag_str_arr.length; k_int += 1){
					if(o.tag_str_arr[k_int] === "popular"){
						html_str += '<div class="popular">popular</div>';
					}
					if(o.tag_str_arr[k_int] === "limitado"){
						html_str += '<div class="limitado">limitado</div>';
					}
					if(o.tag_str_arr[k_int] === "ilimitado"){
						html_str += '<div class="ilimitado">ilimitado</div>';
					}
					if(o.tag_str_arr[k_int] === "exclusivo"){
						html_str += '<div class="exclusivo">exclusivo</div>';
					}
				}

				html_str += 	'<h3>';
				html_str += 		o.membership_name_str;
				html_str += 	'</h3>';
				html_str += 	'<h4>$' + (o.price_in_cents_int/100).toFixed(2) + '</h4>';
				html_str += 	'<section>';
				html_str += 	'<span>';
				html_str += 		o.description_str;
				html_str += 	'</span>';
			
				html_str += 	'</section>';
				// html_str += 	'<figure>';
				html_str += 	'<img src="images/memberships/' + formatWithUnderscores(o.membership_name_str) + '.webp" alt="Image for our ' + o.membership_name_str + '" />';
				// html_str += 	'<span data-action="show_description">';
				// html_str += 		o.description_str;
				// html_str += 	'</span>';
				// html_str += 	'</figure>';
				html_str += '</div>';
			}
		}
		html_str += '</section>';
		
		$("[data-role='memberships']").text("");
		$("[data-role='browse_membership_content']")
				.append(html_str);
	}

	function setUpHandlers(){
		$(document).on("click", "[data-action='show_all'][data-selected='not_selected']", showAll);
		$(document).on("click", "[data-action='show_popular'][data-selected='not_selected']", showPopular);
	}	

	function showAll(){
		$("[data-role='memberships']").text("Fetching all memberships...");
		$("[data-action='show_all']").attr("data-selected", "selected");
		$("[data-action='show_popular']").attr("data-selected", "not_selected");
		loadAllItems();
	}

	function showPopular(){
		$("[data-role='memberships']").text("Fetching popular memberships ...");
		$("[data-action='show_all']").attr("data-selected", "not_selected");
		$("[data-action='show_popular']").attr("data-selected", "selected");
		loadItemsByTag();
	}

	// function toggleDescription(){
	// 	var $card_el = $(this)
	// 			.parent()
	// 			.parent();
	// 	if($card_el.attr("data-showing-description") === "showing"){
	// 		$card_el.attr("data-showing-description", "not_showing");
	// 	}else{
	// 		$card_el.attr("data-showing-description", "showing");
	// 	}
	// }

	return expose;

})();