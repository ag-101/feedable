var initURL = location.href;
var mX = 0;
var mY = 0;
var tooltip = true;

if (initURL.indexOf("#/") > -1) {			  
    initURL = initURL.split("#/")[1];
    window.location = "/"+initURL;
}

function sizeCheck(){
	$('.video_file').stop().css({"height":(($('.video_file').width())/16*9)+"px"});
}


function updateScene(){
    $('.layer').each(function(){
        layerAmount = $(this).attr('class').split("_");
		$(this).css({"margin-top":(-mY*layerAmount[1])/50+"px", "margin-left":(-mX*layerAmount[1])/50+"px"});
    });
}

function flash_message(message){
	$('#flash_message').remove();
	$('body').append('<div id="flash_message" class="alert">'+message+'</div>');
	
	$('#flash_message').animate({opacity:0, "margin-top":"-25px"}, 0, function(){
		$(this).stop().animate({opacity:1, "margin-top":"10px"},"easeOutBack", function(){
			$(this).animate({opacity:1}, 3000, function(){
				$(this).fadeOut("slow", function(){
					$(this).remove();
				});
			});
		});
	});
}



$(document).ready(function(){
	$('body').on('click', '#flash_message a', function(){
		$('#flash_message').remove();
	});
	
	$('#show_menu').on('click', function(e){
		if(!$('#navigation').is(":visible")){

			$('#navigation').fadeIn();
			e.preventDefault();
		}
	});
	
	$('body').on('click', '.navigation a', function(){
		$('.navigation .active').removeClass('active');
		$(this).addClass('active');
	});
	
	$('.modal_link').live('click', function(e){
		$('#loading').fadeIn();
		if ($(this).attr('href').indexOf("?") !== -1){
			delimiter = "&";
		} else{
			delimiter = "?";
		}
		
		$('#modal_content').load($(this).attr('href')+delimiter+"layout=false", function(){
			$('#loading').fadeOut();
			$('#modal').modal();
		});
		e.preventDefault();
	});
	
	$("body").mousemove(function(event) {
	    mX = event.pageX;
	    mY = event.pageY - $(document).scrollTop() - $('#bg').offset().top;
	    updateScene();
	});	  
	
	load_callbacks();	
	
	$('body').on('click', '.loader, .pagination a:not(#photos .pagination a)', function(e){
		$('#loading').stop().fadeIn();
		if($(this).parents('#banner').length){
			$('.page_selected').removeClass('page_selected');
			$(this).addClass('page_selected');
		}

		$('.jwplayer, iframe').remove();
		href = $(this).attr('href');
		window.location.hash = href;
		$('#content').animate({opacity:0}, "fast", function(){
			$("html, body").animate({ scrollTop: 0 }, "slow");
			$('#content_holder').load(href+" #content", function(){
				load_callbacks();
				$('#content').animate({opacity:0}, 0, function(){
					$('#content').animate({opacity:1}, "fast");
				});
			});
		});
		e.preventDefault();
	});
});

$(window).resize(function() {
    sizeCheck();
   	resize_photo(0);
});

function resize_photo(speed){

	if(speed == undefined){
		speed = 200;
	}
	

	$("body").stop().animate({opacity:1}, speed, function(){
		$('#large_container').stop().animate({opacity:1, "height":$('#large').height()+"px"}, speed, function(){
			$(this).css({"overflow":"visible"});
		});
	});
}

function photoCheck(){
	$('.large_image').load(function(){
		resize_photo();
	});
	
	id = $('.large_image').attr('id').split('large_');
	$('#thumb_'+id[1]).addClass('selected');
}

function load_callbacks(){
	$('#loading').stop().fadeOut();
	sizeCheck();
	feed_callbacks();
	
	$(".fancybox_image").fancybox({
		prevEffect		: 'none',
		nextEffect		: 'none',
		closeBtn		: true,
	});
	
	$('.tooltip_show').tooltip({ html: true, delay:100, trigger:"hover", placement:"bottom"});

	if($('#photos').length){
		photoCheck();
	}
}
