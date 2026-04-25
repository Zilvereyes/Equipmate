

TBDListviewMixin = {}

function TBDListviewMixin:OnLoad()

    self.DataProvider = CreateDataProvider();
    self.scrollView = CreateScrollBoxListLinearView();
    self.scrollView:SetElementFactory(function(factory, elementData)
		factory(elementData.template, elementData.initializer);
	end);
	self.scrollView:SetDataProvider(self.DataProvider);

    ---height is defined in the xml keyValues
    local height = self.elementHeight;
    self.scrollView:SetElementExtent(height);

    self.scrollView:SetElementInitializer(self.itemTemplate, GenerateClosure(self.OnElementInitialize, self));
    self.scrollView:SetElementResetter(GenerateClosure(self.OnElementReset, self));

    self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.scrollView);

    self.scrollView:SetPadding(1, 1, 1, 1, 1);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.scrollBox, self.scrollBar, self.scrollView);
    --ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, scrollBoxView)

    local anchorsWithBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 1, -1),
        CreateAnchor("BOTTOMRIGHT", self.scrollBar, "BOTTOMLEFT", -3, 1),
    };
    local anchorsWithoutBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 1, -1),
        CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1),
    };
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.scrollBox, self.scrollBar, anchorsWithBar, anchorsWithoutBar);

end

function TBDListviewMixin:OnElementInitialize(element, elementData, isNew)
    if isNew then
        element:OnLoad();
    end
    local height = self.elementHeight;
    element:SetDataBinding(elementData, height);
    element:Show()

    if self.enableSelection then
        if element.selected then
            element:HookScript("OnMouseDown", function()
                self.scrollView:ForEachFrame(function(f, d)
                    f.selected:Hide()
                end)
                element.selected:Show()
            end)
        end
    end
end

function TBDListviewMixin:OnElementReset(element)
    if element.ResetDataBinding then
        element:ResetDataBinding()
    end
end







TBDNoTemplateListviewMixin = {}


function TBDNoTemplateListviewMixin:OnLoad()

    self.DataProvider = CreateDataProvider();
    self.scrollView = CreateScrollBoxListLinearView();
    self.scrollView:SetDataProvider(self.DataProvider);

    self.scrollView:SetElementFactory(function(factory, elementData)
		factory(elementData.template, elementData.initializer);
	end);
    self.scrollView:SetElementExtentCalculator(function(_, elementData)
        return elementData.height or 20
    end)

    self.scrollView:SetElementResetter(GenerateClosure(self.OnElementReset, self));

    self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.scrollView);

    self.scrollView:SetPadding(1, 1, 1, 1, 1);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.scrollBox, self.scrollBar, self.scrollView);
    --ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, scrollBoxView)

    local anchorsWithBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 1, -1),
        CreateAnchor("BOTTOMRIGHT", self.scrollBar, "BOTTOMLEFT", -5, 1),
    };
    local anchorsWithoutBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 1, -1),
        CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1),
    };
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.scrollBox, self.scrollBar, anchorsWithBar, anchorsWithoutBar);

end

function TBDNoTemplateListviewMixin:OnElementReset(element)
    if element.ResetDataBinding then
        element:ResetDataBinding()
    end
end










TBDTreeviewMixin = {}

function TBDTreeviewMixin:OnLoad()

    self.DataProvider = CreateDataProvider();
    local indent = 10;
	local padLeft = 0;
	local pad = 5;
	local spacing = 1;
    self.scrollView = CreateScrollBoxListTreeListView(indent, pad, pad, padLeft, pad, spacing)
    self.scrollView:SetDataProvider(self.DataProvider);

    ---height is defined in the xml keyValues
    local height = self.elementHeight;
    self.scrollView:SetElementExtent(height);

    self.scrollView:SetElementInitializer(self.itemTemplate, GenerateClosure(self.OnElementInitialize, self));
    self.scrollView:SetElementResetter(GenerateClosure(self.OnElementReset, self));

    self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.scrollView);

    self.scrollView:SetPadding(1, 1, 1, 1, 1);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.scrollBox, self.scrollBar, self.scrollView);
    --ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, scrollBoxView)

    local anchorsWithBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 1, -1),
        CreateAnchor("BOTTOMRIGHT", self.scrollBar, "BOTTOMLEFT", -5, 1),
    };
    local anchorsWithoutBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 1, -1),
        CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1),
    };
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.scrollBox, self.scrollBar, anchorsWithBar, anchorsWithoutBar);

end

function TBDTreeviewMixin:OnElementInitialize(element, elementData, isNew)
    if isNew then
        element:OnLoad();
    end
    local height = self.elementHeight;
    element:SetDataBinding(elementData, height);
    element:Show()

    if self.enableSelection then
        if element.selected then
            element:HookScript("OnMouseDown", function()
                self.scrollView:ForEachFrame(function(f, d)
                    f.selected:Hide()
                end)
                element.selected:Show()
            end)
        end
    end
end

function TBDTreeviewMixin:OnElementReset(element)
    element:ResetDataBinding()
end
