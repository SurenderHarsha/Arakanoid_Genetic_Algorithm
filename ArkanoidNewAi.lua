local score_hundred= 0x0373;
local score_tens=0x0374;
local score_unit =0x0375;
local lives_addr=0x000D;
local ball_pos_y_addr=0x0037;
local ball_pos_x_addr=0x0038;
local no_of_blocks_addr=0x000F;
local pad_addr=0x011C;
local i=0;
local no_controls=15;
local population_size=200;
--local generations = 200;
local cr_rate=0.2;
local mut_rate = 1;
local frame_gap=20;
local max_score=50000;
local steps=0;
local max_steps=1000;
local death=0x0081;
local control_gap=5;
local variation_r=25;
local gen_count=0;

function create_member(sz)
	r='';
	for i=1,sz do
		k=math.random(0,1);
		r=r..k;
	end
	return r;
end

function fitness(n_b,m_b,stps,m_s,sc,m_s)
	return (100-(n_b/m_b)*100);
end

function gen_population(size,n_controls)
	local ret={};
	for i=1,size do
		cand={}		

		for j=1,n_controls do
			if cand[1]==nil then
				cand[1]='';
			end
			k=math.random(0,1)
			cand[1]=cand[1]..k
		end
		cand[2]=0
		ret[i]=cand
		--print(cand)
	end
	return ret
end

function crossover(population,rate)
	local topp=math.floor(rate*(#population));
	--[[
	if gen_count%30==0 then
		control_gap=control_gap-1;
	end
	--]]
	local a=0;
	local b=1;

	top={}
	for i=1,topp do
		table.insert(top,population[i])
	end
	--Add new controls
	for i=1,topp do
		population[i][1]=top[i][1]..create_member(control_gap);
		population[i][2]=0;
	end
	for i=topp+1,#population-10 do
		local p1=math.random(1,topp);
		local p2=math.random(1,topp);
		if math.random(0,10)>5 then

			population[i][1]=top[p1][1]..string.sub(top[p2][1],1,control_gap);
		else
			population[i][1]=top[p2][1]..string.sub(top[p1][1],1,control_gap);
		end
		population[i][2]=0;
	end
	no_controls=no_controls+control_gap;

	
		for i=#population-9,#population do
			population[i][1]=create_member(no_controls);
			population[i][2]=0;
		end
	



	--[[
	for i=topp+1,#population do
		local p1 = math.random(1,topp);
	    local p2 = math.random(1,#population);
	    local s='';
	    local flag=0;
	    local say=math.random(1,no_controls);
	    s=string.sub(top[p1][1],1,say)..string.sub(population[p2][1],(say)+1,no_controls);
	    population[i][1]=s;
	    population[i][2]=0;
	 end
	 --]]
end




function mutation(population,mut_rate)
	local rand_max = 1/mut_rate;
	local a=0;
	local b=1;
    for i=1, #population do
        for j=1, #(population[i][1]) do
            if math.random(1, 120) <= mut_rate then
            	if string.sub(population[i][1],j,j)=='1' then
                population[i][1] = string.sub(population[i][1],1,j-1)..a..string.sub(population[i][1],j+1);
            else
            	population[i][1] = string.sub(population[i][1],1,j-1)..b..string.sub(population[i][1],j+1);
            end
            end
        end
    end
end


local ball_pos_y=memory.readbyte(ball_pos_y_addr);
local no_blocks=memory.readbyte(no_of_blocks_addr);
local pad_pos=memory.readbyte(pad_addr);
local ball_pos_x=memory.readbyte(ball_pos_x_addr);
local max_blocks=memory.readbyte(no_of_blocks_addr);
local is_dead=memory.readbyte(death);
local score=0;
local diff;

local winner=0;
local winner_inp='';
local avg;
local best_f=0;
local cand_num;
local count=0;
local lrv;
local ti;

math.randomseed(os.time());
ss=savestate.create();
savestate.save(ss);
pop=gen_population(population_size,no_controls)


while true do
	if winner==1 then
		break;
	end
	gen_count=gen_count+1;
	
	avg=0;
	for i=1,population_size do

		if winner==1 then
			break;
		end
		--print("LOADING");
		savestate.load(ss)
		local cand=pop[i][1]
		--pop[i][1]=0;
		count=0;
		--print(cand[1]);
		score=0;
		steps=0;
		local j=1;
		ti=1;
		while ti<=no_controls do

			steps=steps+1;
			--READING MEMORY
			ball_pos_y=memory.readbyte(ball_pos_y_addr);
			no_blocks=memory.readbyte(no_of_blocks_addr);
			pad_pos=memory.readbyte(pad_addr);
			ball_pos_x=memory.readbyte(ball_pos_x_addr);
			is_dead=memory.readbyte(death);
			diff=pad_pos-ball_pos_x;
			
			--print(100-(no_blocks/max_blocks)*100);
			if is_dead==0 then
				pop[i][2]=fitness(no_blocks,max_blocks,steps,max_steps,score,max_score);
				avg=avg+pop[i][2];
				if pop[i][2]>best_f then
					best_f=pop[i][2];
				end
				break;
			end
			if pad_pos>=180 or pad_pos<=10 then
				pop[i][2]=fitness(no_blocks,max_blocks,steps,max_steps,score,max_score);
				avg=avg+pop[i][2];
				if pop[i][2]>best_f then
					best_f=pop[i][2];
				end
				break;
			end
			
			if no_blocks<=0 then
				winner_inp=cand;
				winner=1;
				break;
			end
			if ball_pos_y>=230 then
				--print(score);
				pop[i][2]=fitness(no_blocks,max_blocks,steps,max_steps,score,max_score);
				avg=avg+pop[i][2];
				if pop[i][2]>best_f then
					best_f=pop[i][2];
				end
				break;
			end
			if count<frame_gap then
				for k=1,frame_gap-count do

					gui.text(0, 9, "Generation:"..gen_count);
					gui.text(0,39,"Candidate:"..i)
					gui.text(0,19,"BestFit:"..best_f);
					--gui.text(o,39,"INPUT:"..cand);
					gui.text(0,29,"Blocks:"..no_blocks);
					gui.text(0,49,"Control:"..ti);
					tbl={
	        	up      = 0,
	        	down    = 0,
	        	left    = lrv,
	        	right   = not lrv,
	        	A       = 1,
	        	B       = 1,
	        	start   = false,
	        	select  = false
	        	};
	        joypad.set(1,tbl);
	        		score=memory.readbyte(score_hundred)*100+memory.readbyte(score_tens)*10+memory.readbyte(score_unit);
					emu.frameadvance();

					count=count+1
				end
			else

			count=0
			--print(string.sub(cand,j,j));
			if string.sub(cand,ti,ti)=='1' then
				lrv = true;
			else
				lrv = false;
			end
			

			
				--local lrv = math.random(1, 10) > 5;
	    	tbl={
	        	up      = 0,
	        	down    = 0,
	        	left    = lrv,
	        	right   = not lrv,
	        	A       = 0,
	        	B       = 0,
	        	start   = false,
	        	select  = false
	        	};
	        joypad.set(1,tbl);
	        
			
			
			gui.text(0, 9, "Generation:"..gen_count);
			gui.text(0,39,"Candidate:"..i)
			gui.text(0,19,"BestFit:"..best_f);
			--gui.text(o,39,"INPUT:"..cand);
			--avg=avg/population_size;
			gui.text(0,29,"Blocks:"..no_blocks);
			gui.text(0,49,"Control:"..ti);
			score=memory.readbyte(score_hundred)*100+memory.readbyte(score_tens)*10+memory.readbyte(score_unit);
			emu.frameadvance();
			ti=ti+1;
		end
		end

		
		--print(pop[i][1]);
	end
	table.sort(pop,
        function(a, b)

            if a[2] > b[2] then
                return true;
            else
                return false;
            end
        end);
	--print(pop[1][2]);
	crossover(pop,cr_rate);
	--print(pop);
	avg=avg/population_size;
	mutation(pop,mut_rate);
	--print(pop);
	print(avg);
	--emu.frameadvance()
end



--Winner

while true do
	
	
		savestate.load(ss)
		local cand=winner_inp;
		count=0;
		--print(cand[1]);
		score=0;
		steps=0;
		local j=1;
		ti=1;
		while ti<=no_controls do

			steps=steps+1;
			--READING MEMORY
			ball_pos_y=memory.readbyte(ball_pos_y_addr);
			no_blocks=memory.readbyte(no_of_blocks_addr);
			pad_pos=memory.readbyte(pad_addr);
			ball_pos_x=memory.readbyte(ball_pos_x_addr);
			is_dead=memory.readbyte(death);
			diff=pad_pos-ball_pos_x;
			
			--print(100-(no_blocks/max_blocks)*100);
			if is_dead==0 then
				--pop[i][2]=fitness(no_blocks,max_blocks,steps,max_steps,score,max_score);
				--avg=avg+pop[i][2];
				--if pop[i][2]>best_f then
				--	best_f=pop[i][2];
				--end
				break;
			end
			if pad_pos>=180 or pad_pos<=10 then
				--[[pop[i][2]=fitness(no_blocks,max_blocks,steps,max_steps,score,max_score);
				avg=avg+pop[i][2];
				if pop[i][2]>best_f then
					best_f=pop[i][2];
				end
				--]]
				break;
			end
			
			if no_blocks<=0 then
				--winner_inp=cand[1];
				--winner=1;
				break;
			end
			if ball_pos_y>=230 then
				--print(score);
				--pop[i][2]=fitness(no_blocks,max_blocks,steps,max_steps,score,max_score);
				--avg=avg+pop[i][2];
				--if pop[i][2]>best_f then
				--	best_f=pop[i][2];
				--end
				break;
			end
			if count<frame_gap then
				for k=1,frame_gap-count do
					--[[
					gui.text(0, 9, "Generation:"..gen_count);
					gui.text(0,39,"Candidate:"..i)
					gui.text(0,19,"BestFit:"..best_f);
					--gui.text(o,39,"INPUT:"..cand);
					gui.text(0,29,"Blocks:"..no_blocks);
					gui.text(0,49,"Control:"..ti);--]]
					tbl={
	        	up      = 0,
	        	down    = 0,
	        	left    = lrv,
	        	right   = not lrv,
	        	A       = 1,
	        	B       = 1,
	        	start   = false,
	        	select  = false
	        	};
	        joypad.set(1,tbl);
	        		score=memory.readbyte(score_hundred)*100+memory.readbyte(score_tens)*10+memory.readbyte(score_unit);
					emu.frameadvance();

					count=count+1
				end
			else

			count=0
			--print(string.sub(cand,j,j));
			if string.sub(cand,ti,ti)=='1' then
				lrv = true;
			else
				lrv = false;
			end
			

			
				--local lrv = math.random(1, 10) > 5;
	    	tbl={
	        	up      = 0,
	        	down    = 0,
	        	left    = lrv,
	        	right   = not lrv,
	        	A       = 0,
	        	B       = 0,
	        	start   = false,
	        	select  = false
	        	};
	        joypad.set(1,tbl);
	        
			
			--[[
			gui.text(0, 9, "Generation:"..gen_count);
			gui.text(0,39,"Candidate:"..i)
			gui.text(0,19,"BestFit:"..best_f);
			--gui.text(o,39,"INPUT:"..cand);
			--avg=avg/population_size;
			gui.text(0,29,"Blocks:"..no_blocks);
			gui.text(0,49,"Control:"..ti);
			--]]
			score=memory.readbyte(score_hundred)*100+memory.readbyte(score_tens)*10+memory.readbyte(score_unit);
			emu.frameadvance();
			ti=ti+1;
		end
		end

		
		--print(pop[i][1]);
	
	
	--emu.frameadvance()
end






