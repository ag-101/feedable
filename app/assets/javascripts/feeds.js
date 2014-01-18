// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function(){
	$('body').on('click', '#display_options .btn', function(e){
		id = $(this).prop('id').split('display_')
		reset_layout(id[1], $(this));
		e.preventDefault();
	});

	$('body').on('click', '.save', function(e){
		if(!$(this).hasClass('disabled')){
			this_button = $(this);
			$(this_button).addClass('disabled');
			$(this_button).toggleClass('btn-warning');
			feed_content_container = $(this).parents('.feed_content_container');
				$.ajax({
				  type: "GET",
				  dataType: 'html',
				  url: $(this).prop('href'),
				}).done(function(msg) {
					$(this_button).removeClass('disabled');
					if(msg == "unsaved"){
						$('#saved').find(feed_content_container).addClass('unsaved');
					} else{
						$('#saved').find(feed_content_container).removeClass('unsaved');
					}
					flash_message("<strong>Item "+msg+"</strong>.  <a href='/feeds/saved' class='loader'>View saved items</a>.");
				}).error(function(msg){
					$(this_button).removeClass('disabled');
					alert("There was an error saving the item.")
				});

		}
		e.preventDefault();
	});

	$.ajax({
	  type: "GET",
	  dataType: 'html',
	  url: "/feeds/update_time",
	});
	
	$('body').on('click', '.feed_load', function(e){
		$('#subscriptions .selected').removeClass('selected');
		$(this).addClass('selected');
		
		$("html, body").animate({ scrollTop: 0 }, "slow");
		
		if($('#close_subscriptions').is(":visible")){
			toggle_subscriptions();	
		}
		
		$('#loading').fadeIn();
		
		href = $(this).attr('href');
		window.location.hash = href;
		
		$('.span9.feed_loader').fadeOut("fast", function(){
			$(this).load(href+" #feed_content", function(){
				$(this).fadeIn();
				feed_callbacks(false);
				$('#loading').stop().fadeOut();
			});
		});

		e.preventDefault();
	});
	
	$('body').on('click', '.title_item', function(e){
		
		$(this).parents('.feed_content_container').find('.grid_item').slideDown();
		$(this).parents('.feed_contents_container').find('.span4').removeClass('span4');
		$(this).parents('.feed_content_container').addClass('opened');
		
		offset = 0;
		$('html,body').animate({ scrollTop: ($(this).parents('.feed_content_container').offset().top-offset)}, 'slow');

		e.preventDefault();
	});
	
	$('body').on('change', '#feed_feed_type', function(e){
		if($(this).val() == 'twitter_timeline'){
			$('#form_url').slideUp();
			$('#form_twitter_username').removeClass('hidden').slideUp(0, function(){
				$(this).slideDown();
			});
		} else{
			$('#form_twitter_username').slideUp();
			$('#form_url').fadeIn(0).removeClass('hidden').slideUp(0, function(){
				$(this).slideDown();
			});
		}
	});
	
	$('body').on('change', '#twitter_username', function(e){
		$('.modal-footer .actions .btn-primary').addClass('disabled');
		val = $('#twitter_username').val();
		if(val != "" && val != undefined){
				$.ajax({
				  type: "GET",
				  dataType: 'html',
				  url: "/feeds/find_twitter_id?username="+val,
				}).done(function(msg) {
					$('#feed_url').val('http://api.twitter.com/1/statuses/following_timeline.rss?user_id='+msg);
					$('.modal-footer .actions .btn-primary').removeClass('disabled');
				}).error(function(msg){
					alert("There was an error fetching the username");
				});
			}
	});
	
	$('body').on('click', '.toggle_subscriptions', function(e){
		toggle_subscriptions();		
		e.preventDefault();
	});
	
	$('body').on('click', '#library .feed .btn, #library .subscribe_toggle', function(e){
		if(!$(this).hasClass('sub_disabled')){
			$(this).parents('.feed').find('.btn-group .btn').toggleClass('btn-primary').addClass('sub_disabled');
			

			$(this).parents('.feed').toggleClass('subscribed unsubscribed');
			
			$.ajax({
			  type: "GET",
			  dataType: 'html',
			  url: $(this).parents('.feed').find('.subscribe_toggle').prop('href'),
			}).done(function(msg) {
				$(this).parents('.feed_container').html(msg);
				$('#library a, #library .btn').removeClass('sub_disabled');
				feed_callbacks();
			}).error(function(msg){
				$('#subscriptions_container').html(msg);
				feed_callbacks();
			});
		}
		e.preventDefault();
	});
	
	$(window).on('scroll', function() {	
		
		if($('.load_more').length > 0 && $('.load_more').is(":visible")){
			if ($(document).scrollTop() >= $('.load_more').offset().top - $(window).height()){
			 $('.load_more').click();
			}
		}
	});
	
	$('body').on('click', '#subscriptions .btn', function(e){
		if($('#show_subscriptions').text() == "Hide subscriptions" && $('#show_subscriptions').is(":visible")){
			toggle_subscriptions();
		}
	});
	
	$('body').on('click', '.enable_autoload', function(e){
		$('.feed_pagination .hidden-desktop').slideUp().remove();
		$('.feed_pagination .visible-desktop').addClass('force_display').fadeIn().slideDown();
		$('.load_more').click();
		e.preventDefault();
	});	
	
	$('body').on('click', '.load_more', function(e){
		$(this).text('Loading more articles...');
	    $(this).addClass('disabled loading_more');
	    $(this).removeClass('load_more');
		
		$.ajax({
		  type: "GET",
		  dataType: 'html',
		  url: $(this).prop('href'),
		}).done(function(msg) {
			$('.loading_more').remove();
			$('#feed_content').append(msg);
			feed_callbacks();
		}).error(function(msg){
			alert("Error loading content");
		});
		
		e.preventDefault();
	});
	
	$('body').on('click', '.feed_content', function(){
		expand_content($(this));
	});
});

function reset_layout(layout, object){
	if($('#saveable').length > 0){
		save_display_setting(layout);
	}
	
	if(layout == "grid"){
		$('.grid_item').fadeIn(0);	
		$('.grid_item').addClass('feed_content_fixed_height');
	}
	
	if(layout == "list"){
		$('.grid_item').fadeOut(0);
	}
	
	if(layout == "magazine"){
		$('.grid_item').fadeIn();
		$('.grid_item').addClass('feed_content_fixed_height');
	}	
	
	$('.full-image-disabled').removeClass('full-image-disabled').addClass('full-image');
	
	$('.opened').removeClass('opened');	
	$('#feed_content').removeClass().addClass(layout);
	$('.orphaned').removeClass('orphaned').removeClass('double_orphaned');
	$('.forced_full_width').removeClass('forced_full_width');
	$('.feed_content_container').addClass('span4');
	$(object).parents('.btn-group').find('.active').removeClass('active');
	$(object).addClass('active');	
	$('.magazine_fixed').removeClass('magazine_fixed');
	animate_content();
}

function expand_content(object, supress){
	if(supress == undefined){
		supress = false;
	}
	
	$(object).find('audio').prop('preload', 'metadata');
	if(supress == false){
		$(object).removeClass('full-image').removeClass('feed_content_fixed_height').addClass('full-image-disabled');
		$(object).parents('.feed_content_container').addClass('opened').removeClass('span4');
	}
	else{
		$(object).parents('.feed_content_container').addClass('forced_full_width').removeClass('span4');
	}
	
		$(object).parents('.feed_contents_container').removeClass('row-fluid').addClass('orphaned');
		$(object).parents('.feed_contents_container').append('<div class="clear"></div>');


		if ($('.feed_content').index(object) % 3 == 1  || $(object).parents('.feed_contents_container').find('.span4').length == 1){
			$(object).parents('.feed_contents_container').addClass('double_orphaned');
		}
		
		$(object).parents('.feed_contents_container').find('.first_orphan').removeClass('first_orphan');
		$(object).parents('.feed_contents_container').find('.span4:first').addClass('first_orphan')
	
	if(supress == false){	
		offset = 0;
   		$('html,body').animate({ scrollTop: ($(object).parents('.feed_content_container').offset().top-offset)}, 'slow');
   	}
}

function save_display_setting(type){
	$.ajax({
	  type: "GET",
	  dataType: 'html',
	  data: 'feed_display_setting='+type,
	  url: "/feeds/set_display_setting",
	});
}

function toggle_subscriptions(){
	if($('#subscriptions').is(":visible")){
		$('#show_subscriptions').slideDown();
		$('#subscriptions').animate({"left":"-100%"}).fadeOut();
		$('#user_options').animate({ "top":"18px"});
	} else{
		$('#show_subscriptions').slideUp();
		$('#subscriptions').fadeIn(0).animate({"left":"0"});
		$('#user_options').animate({ "top":"-100px"});
	}

}

function display_updates(message, message_delay){
	setTimeout(function(){
		$('#parsed_feed_names').animate({opacity:1, "left":"10px"},0, function(){
			$(this).text(message);
			$(this).animate({opacity:0, "left":"25px"}, 1000);
		});

	}, message_delay);
}

function parse_feeds(total_to_update, already_parsed){
	$.ajax({
	  type: "GET",
	  dataType: 'json',
	  data: "total_to_update="+total_to_update+"&already_parsed="+already_parsed,
	  url: "/feeds/parse_feeds",
	}).done(function(msg){
		
		if(msg){			
			$('.update_text .number').text(parseFloat($('.update_text .number').text())+msg["new_items"]);

			if(msg["total_to_update"] - msg["already_parsed"] <= 0){
				$('#parse_feeds .bar').stop().animate({width:"100%"}, 1000, function(){
					$('#parse_feeds').slideUp();
					
					if(parseFloat($('.update_text .number').text()) > 0){					
						$('.reload_feeds').text("Load "+$('.update_text .number').text()+" new items");
						$('.reload_feeds').removeClass('hidden').slideUp(0).slideDown("slow");
					}
				});
				

				
			} else{
				
				$('#parse_feeds').fadeIn();
				if(total_to_update == 0){
					total_to_update = msg["total_to_update"];
				}
				
				if(total_to_update - already_parsed > 0){
					percent = (msg["already_parsed"] / total_to_update) * 100
					$('#parse_feeds .bar').stop().animate({width:percent+"%"}, 3000, function(){
						parse_feeds(total_to_update, msg["already_parsed"]);
					});
				}
				
				updated_items = msg["updated"].split(";");
				
				for (var i=0;i<updated_items.length;i++){
					display_updates(updated_items[i],(i*1000)+250)
				}
			}
		}
	}).error(function(msg){
		$('#parse_feeds').fadeOut();
		alert("Loading cancelled");
		$('#parse_feeds .bar').stop().animate({width:"100%"}, 1000, function(){
			$('#parse_feeds').fadeOut("slow");
		});
	});	
}
function feed_callbacks(animate_subscriptions){
	$('.read_line').parents('.feed_contents_container').addClass('orphaned')
	if($('#parse_feeds').length > 0){
		setTimeout(function(){parse_feeds(0, 0)}, 1500);
	}
}


function display_subscription_message(){
	$('.no_subscriptions_message').animate({opacity:0});
	$('.subscription_message').animate({ opacity:0, "margin-left":"400px" }, 2000, "easeInCirc", function(){
		$(this).remove();
	});
}

function animate_content(){
	$('.list .feed_content_container').animate({opacity:0, "margin-top":"50px"}, 0);
	$(".list .feed_content_container").each(function(index) {
	    $(this).delay(100*index).animate({opacity:1, "margin-top":"0px"},"slow","easeOutBack");
	});
	
	$('.grid .feed_content_container, .magazine .feed_content_container').animate({opacity:0}, 0);
	$(".grid .feed_content_container, .magazine .feed_content_container").each(function(index) {
	    $(this).delay(100*index).animate({opacity:1},"slow");
	});
}
