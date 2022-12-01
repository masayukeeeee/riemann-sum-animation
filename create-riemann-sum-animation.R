#---------------------------------------------------------
# settings
# interval [a,b]
a <- -sqrt(2) - 0.3
b <- sqrt(2) + 0.3

# target function
f <- function(x) x^3 - 2*x + 3

# points of x for plot
x <- seq(a, b, 0.01)

# N, where move n to lim_{n -> N}
split_ns <- seq(10, 310, 10)

# movie setting
duration <- 5

#---------------------------------------------------------
# bottom left -> top left -> top right -> bottom right
# (xi, 0) -> (xi, f(xi+1)) -> (xi+1, f(xi+1)) -> (xi+1, 0)

if(exists("riemann_splits")){
  rm(riemann_splits)
  print("removed 'riemann_splits'")
}

for(split_n in split_ns){
  xbars <- seq(a,b,length.out=split_n+1)
  split_x <- matrix(rep(xbars, each=2), ncol=2, byrow=T) %>% 
    as_tibble() %>% set_names(c("x3", "x4"))
  split_x_lag1  <- dplyr::lag(split_x,1) %>% set_names(c("x1", "x2"))
  ps <- bind_cols(split_x_lag1, split_x) %>% drop_na() %>% 
    mutate(y1 = 0, y2 = f(x3), y3 = f(x3), y4 = 0)
  xs <- ps %>% select(x1, x2, x3, x4) %>% as.matrix() %>% t() %>% as.vector()
  ys <- ps %>% select(y1, y2, y3, y4) %>% as.matrix() %>% t() %>% as.vector()
  ps_longer <- data.frame(x=xs, y=ys) %>% as_tibble() %>% mutate(n = split_n)
  
  if(!exists("riemann_splits")){
    riemann_splits <- ps_longer
  }else{
    riemann_splits <- bind_rows(riemann_splits, ps_longer)
  }
}
#---------------------------------------------------------
# dataframe to drow line of the function 
f_line <- data.frame(
  x=x,
  y=f(x)
)

#---------------------------------------------------------
# create ggplot
p <- ggplot(f_line, aes(x=x, y=y), color="blue") +
  geom_line(inherit.aes=F, data=riemann_splits, 
            aes(x=x, y=y)) +
  geom_ribbon(aes(ymin=0, ymax=y), fill="skyblue", alpha=0.4) +
  geom_line() +
  labs(title = "n = {closest_state}") +
  theme_bw()

#---------------------------------------------------------
# create animation by gganimate
anim <- p + transition_states(n)

#---------------------------------------------------------
# save this animation as gif at current directory
output <- animate(anim, nframes=length(ns), duration=duration)
anim_save("riemann_sum_animation.gif", output)

# example: failed setting
# output <- animate(anim, nframes=100, duration=10)
# anim_save("riemann_sum_animation_failed.gif", output)
#---------------------------------------------------------
# print success message
msg <- sprintf("[Success!] gif file was saved in %s", getwd())
message(msg)
#---------------------------------------------------------