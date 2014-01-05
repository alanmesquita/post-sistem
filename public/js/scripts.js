jQuery(function(){
    $('.open-reply').on('click', function(){
        $(this).closest('.post-cell').find('.post-reply').toggle();
    })

    $('form').on('submit', function(e){
        var text = $(this).find('textarea');
        if(text.val() == '') {
            
            e.preventDefault();
            alert('Ops! Voce precisa deixar um comentario!')
            text.css('border','1px solid red');
        }
    })
});

