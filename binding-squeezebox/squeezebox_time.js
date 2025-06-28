(function(i){ 
    var s = ~~(i%60);
    return (~~(i/60) + ':' + ((s < 10) ? '0' : '') + s);
})(input)
